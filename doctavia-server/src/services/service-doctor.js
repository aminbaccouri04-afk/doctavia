const { Doctor, User, Profile, Location, Specialty, AvailabilitySlot, Review, Offering, Category, Equipment, Language, sequelize } = require('../models');
const { Op } = require('sequelize');

class DoctorService {
  /**
   * Search for doctors based on specialty, date, and geolocation (proximity).
   */
  static async searchDoctors(filters) {
    const { specialty, date, lat, lng, radius = 50 } = filters;
    
    let whereClause = {};
    let includeClauses = [
      {
        model: User,
        as: 'user',
        attributes: ['email'], // Exclude password and sensitive stuff
        include: [{
          model: Profile,
          as: 'profiles',
          attributes: ['fullName', 'avatarUrl'],
          where: { relationship: 'Self' },
          required: false
        }]
      },
      {
        model: Location,
        as: 'offices',
        through: { attributes: [] }
      },
      {
        model: AvailabilitySlot,
        as: 'schedule',
        where: { isBooked: false },
        required: false // We still want to return doctors even if they don't have slots, unless filtered
      },
      {
        model: Offering,
        as: 'offerings'
      },
      {
        model: Category,
        as: 'categories',
        through: { attributes: [] }
      },
      {
        model: Equipment,
        as: 'equipment',
        through: { attributes: [] }
      },
      {
        model: Language,
        as: 'languages',
        through: { attributes: [] }
      }
    ];

    // Filter by Specialty (using Many-to-Many join)
    if (specialty) {
      includeClauses.push({
        model: Specialty,
        as: 'specialties',
        where: { name: { [Op.like]: `%${specialty}%` } },
        through: { attributes: [] },
        required: true
      });
    }

    // Filter by Date (availability)
    if (date) {
      const startOfDay = new Date(date);
      startOfDay.setHours(0, 0, 0, 0);
      const endOfDay = new Date(date);
      endOfDay.setHours(23, 59, 59, 999);

      includeClauses[2].where.startTime = {
        [Op.between]: [startOfDay, endOfDay]
      };
      includeClauses[2].required = true; // Only doctors with available slots on this date
    }

    // Geospatial Search (Haversine formula in MySQL)
    if (lat && lng) {
      const haversine = `(
        6371 * acos(
          cos(radians(${parseFloat(lat)}))
          * cos(radians(offices.latitude))
          * cos(radians(offices.longitude) - radians(${parseFloat(lng)}))
          + sin(radians(${parseFloat(lat)})) * sin(radians(offices.latitude))
        )
      )`;

      includeClauses[1].where = sequelize.where(
        sequelize.literal(haversine),
        '<=',
        parseFloat(radius)
      );
      includeClauses[1].required = true; // Must have an office within radius
    }

    try {
      const doctors = await Doctor.findAll({
        where: whereClause,
        attributes: {
          include: [
            [
              sequelize.literal(`(
                SELECT AVG(rating)
                FROM reviews AS r
                JOIN appointments AS a ON r.appointment_id = a.id
                JOIN availability_slots AS s ON a.slot_id = s.id
                WHERE s.doctor_id = Doctor.id
              )`),
              'avgRating'
            ],
            [
              sequelize.literal(`(
                SELECT COUNT(r.id)
                FROM reviews AS r
                JOIN appointments AS a ON r.appointment_id = a.id
                JOIN availability_slots AS s ON a.slot_id = s.id
                WHERE s.doctor_id = Doctor.id
              )`),
              'reviewCount'
            ]
          ]
        },
        include: includeClauses
      });

      return doctors;
    } catch (error) {
      console.error('GEOSPATIAL ERROR 💥:', error);
      throw error;
    }
  }

  static async getDoctorById(id) {
    const doctor = await Doctor.findByPk(id, {
      attributes: {
        include: [
          [
            sequelize.literal(`(
              SELECT AVG(rating)
              FROM reviews AS r
              JOIN appointments AS a ON r.appointment_id = a.id
              JOIN availability_slots AS s ON a.slot_id = s.id
              WHERE s.doctor_id = Doctor.id
            )`),
            'avgRating'
          ],
          [
            sequelize.literal(`(
              SELECT COUNT(r.id)
              FROM reviews AS r
              JOIN appointments AS a ON r.appointment_id = a.id
              JOIN availability_slots AS s ON a.slot_id = s.id
              WHERE s.doctor_id = Doctor.id
            )`),
            'reviewCount'
          ]
        ]
      },
      include: [
        { 
          model: User, 
          as: 'user',
          attributes: ['email'],
          include: [{
            model: Profile,
            as: 'profiles',
            attributes: ['fullName', 'avatarUrl'],
            where: { relationship: 'Self' },
            required: false
          }]
        },
        { model: Location, as: 'offices', through: { attributes: [] } },
        { model: AvailabilitySlot, as: 'schedule', where: { isBooked: false }, required: false },
        { model: Offering, as: 'offerings' },
        { model: Category, as: 'categories', through: { attributes: [] } },
        { model: Equipment, as: 'equipment', through: { attributes: [] } },
        { model: Language, as: 'languages', through: { attributes: [] } }
      ]
    });
    return doctor;
  }

  /**
   * Toggles a doctor in the user's favorites list.
   */
  static async toggleFavorite(userId, doctorId) {
    const { Favorite } = require('../models');
    
    const existing = await Favorite.findOne({ where: { userId, doctorId } });
    
    if (existing) {
      await existing.destroy();
      return { isFavorite: false };
    } else {
      await Favorite.create({ userId, doctorId });
      return { isFavorite: true };
    }
  }

  static async updateProfile(userId, updateData) {
    const doctor = await Doctor.findOne({ where: { userId } });
    if (!doctor) throw new AppError('Doctor profile not found', 404);

    const allowedFields = ['bio', 'experienceYears', 'education'];
    const filteredData = {};
    
    Object.keys(updateData).forEach(key => {
      if (allowedFields.includes(key)) {
        filteredData[key] = updateData[key];
      }
    });

    await doctor.update(filteredData);

    // Update Associations (Relational)
    if (updateData.categories) { // Map 'categories' input to 'Specialties' table
      const specialties = await Promise.all(
        updateData.categories.map(name => Specialty.findOrCreate({ where: { name } }).then(([s]) => s))
      );
      await doctor.setSpecialties(specialties);
    }

    if (updateData.services) { // Map 'services' input to 'Categories' table
      const categories = await Promise.all(
        updateData.services.map(name => Category.findOrCreate({ where: { name } }).then(([c]) => c))
      );
      await doctor.setCategories(categories);
    }

    if (updateData.equipment) {
      const equipment = await Promise.all(
        updateData.equipment.map(name => Equipment.findOrCreate({ where: { name } }).then(([e]) => e))
      );
      await doctor.setEquipment(equipment);
    }

    if (updateData.languages) {
      const languages = await Promise.all(
        updateData.languages.map(name => Language.findOrCreate({ where: { name } }).then(([l]) => l))
      );
      await doctor.setLanguages(languages);
    }

    return this.getDoctorById(doctor.id);
  }
}

module.exports = DoctorService;

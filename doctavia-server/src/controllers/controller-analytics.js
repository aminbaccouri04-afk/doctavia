const { Appointment, AvailabilitySlot, Doctor, Review, sequelize } = require('../models');
const AppError = require('../utils/util-app-error');

exports.getKPIs = async (req, res, next) => {
  try {
    let doctorIds = [];

    if (req.user.role === 'doctor') {
      const doctor = await Doctor.findOne({ where: { userId: req.user.id } });
      if (!doctor) return next(new AppError('Doctor profile not found', 404));
      doctorIds = [doctor.id];
    } else if (req.user.role === 'secretary') {
      const { PracticeStaff } = require('../models');
      const links = await PracticeStaff.findAll({ where: { userId: req.user.id } });
      doctorIds = links.map(l => l.doctorId);
    }

    if (doctorIds.length === 0) {
      return res.status(200).json({ status: 'success', data: { kpis: {} } });
    }

    // 1. Fulfillment Rate & Status Breakdown
    const [statusBreakdown] = await sequelize.query(`
      SELECT
        COUNT(*)                                                          AS total_appointments,
        SUM(CASE WHEN a.status = 'completed'  THEN 1 ELSE 0 END)        AS completed_count,
        SUM(CASE WHEN a.status = 'confirmed'  THEN 1 ELSE 0 END)        AS upcoming_count,
        SUM(CASE WHEN a.status = 'cancelled'  THEN 1 ELSE 0 END)        AS cancelled_count,
        ROUND(
          100.0 * SUM(CASE WHEN a.status = 'completed' THEN 1 ELSE 0 END)
          / NULLIF(SUM(CASE WHEN a.status IN ('completed', 'cancelled') THEN 1 ELSE 0 END), 0),
          1
        )                                                                 AS fulfillment_rate_pct
      FROM appointments a
      JOIN availability_slots s ON a.slot_id = s.id
      WHERE s.doctor_id IN (:doctorIds)
    `, { replacements: { doctorIds }, type: sequelize.QueryTypes.SELECT });

    // 2. Peak Booking Hours
    const peakHours = await sequelize.query(`
      SELECT
        HOUR(a.start_time_snapshot)  AS hour_of_day,
        COUNT(*)                     AS booking_count
      FROM appointments a
      JOIN availability_slots s ON a.slot_id = s.id
      WHERE s.doctor_id IN (:doctorIds)
        AND a.status != 'cancelled'
      GROUP BY HOUR(a.start_time_snapshot)
      ORDER BY booking_count DESC
      LIMIT 5
    `, { replacements: { doctorIds }, type: sequelize.QueryTypes.SELECT });

    // 3. 30-Day Volume Trend
    const volumeTrend = await sequelize.query(`
      SELECT
        DATE(a.start_time_snapshot)  AS date,
        COUNT(*)                     AS bookings
      FROM appointments a
      JOIN availability_slots s ON a.slot_id = s.id
      WHERE s.doctor_id   IN (:doctorIds)
        AND a.status      != 'cancelled'
        AND a.start_time_snapshot >= DATE_SUB(NOW(), INTERVAL 30 DAY)
      GROUP BY DATE(a.start_time_snapshot)
      ORDER BY date ASC
    `, { replacements: { doctorIds }, type: sequelize.QueryTypes.SELECT });

    // 4. Average Rating
    const [ratingStats] = await sequelize.query(`
      SELECT
        ROUND(AVG(r.rating), 1) AS average_rating,
        COUNT(r.id)             AS total_reviews
      FROM reviews r
      JOIN appointments a ON r.appointment_id = a.id
      JOIN availability_slots s ON a.slot_id = s.id
      WHERE s.doctor_id IN (:doctorIds)
    `, { replacements: { doctorIds }, type: sequelize.QueryTypes.SELECT });

    // 5. Revenue Stats (from Invoices)
    const revenueStats = await sequelize.query(`
      SELECT
        status,
        SUM(amount) AS total_amount,
        COUNT(*)    AS count
      FROM invoices
      WHERE doctor_id IN (:doctorIds)
      GROUP BY status
    `, { replacements: { doctorIds }, type: sequelize.QueryTypes.SELECT });

    res.status(200).json({
      status: 'success',
      data: {
        kpis: {
          ...statusBreakdown,
          ...ratingStats,
          peakHours,
          volumeTrend,
          revenue: revenueStats
        }
      }
    });
  } catch (err) {
    next(err);
  }
};

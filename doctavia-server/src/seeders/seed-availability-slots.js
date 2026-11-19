'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const now = new Date();
    const [doctors] = await queryInterface.sequelize.query('SELECT id FROM doctors');
    const slotsData = [];
    
    // Future slots
    for (const d of doctors) {
      for (let i = 1; i <= 14; i++) {
        const date = new Date(now);
        date.setDate(now.getDate() + i);
        if (date.getDay() === 0 || date.getDay() === 6) continue;
        
        for (let h = 9; h < 17; h++) {
          if (h === 13) continue;
          const slotDate = new Date(date);
          slotDate.setHours(h, 0, 0, 0);
          
          slotsData.push({
            doctor_id: d.id,
            start_time: slotDate,
            end_time: new Date(slotDate.getTime() + 30 * 60000),
            is_booked: false,
            created_at: now,
            updated_at: now
          });
        }
      }
    }
    
    // Past slots (for historical appointments)
    for (let di = 0; di < doctors.length; di++) {
      const d = doctors[di];
      for (let i = 0; i < 30; i++) {
        if (i % doctors.length !== di) continue;
        
        const pastDate = new Date();
        pastDate.setMonth(now.getMonth() - (i % 6 + 1));
        pastDate.setDate(10 + (i % 15));
        
        slotsData.push({
          doctor_id: d.id,
          start_time: pastDate,
          end_time: new Date(pastDate.getTime() + 30 * 60000),
          is_booked: true,
          created_at: now,
          updated_at: now
        });
      }
    }
    
    await queryInterface.bulkInsert('availability_slots', slotsData);
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('availability_slots', null, {});
  }
};

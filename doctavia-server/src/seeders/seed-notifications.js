'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const now = new Date();
    const [patients] = await queryInterface.sequelize.query("SELECT id FROM users WHERE role = 'patient' ORDER BY email ASC LIMIT 5");
    const [doctors] = await queryInterface.sequelize.query("SELECT id FROM users WHERE role = 'doctor' ORDER BY email ASC LIMIT 5");
    
    const notifsData = [];
    for (let i = 0; i < 5; i++) {
      if (patients[i]) {
        notifsData.push({
          user_id: patients[i].id,
          title: 'Appointment Reminder',
          message: 'You have an upcoming appointment tomorrow at 10:00 AM.',
          is_read: false,
          created_at: now,
          updated_at: now
        });
      }
      if (doctors[i]) {
        notifsData.push({
          user_id: doctors[i].id,
          title: 'New Booking',
          message: 'A new patient has booked an appointment with you.',
          is_read: false,
          created_at: now,
          updated_at: now
        });
      }
    }
    
    await queryInterface.bulkInsert('notifications', notifsData);
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('notifications', null, {});
  }
};

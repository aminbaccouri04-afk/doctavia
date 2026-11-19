'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const now = new Date();
    const [pastAppts] = await queryInterface.sequelize.query("SELECT id, start_time_snapshot FROM appointments WHERE status = 'completed'");
    
    const reviewsData = [];
    for (let i = 0; i < pastAppts.length; i++) {
      if (i % 3 === 0) {
        const appt = pastAppts[i];
        reviewsData.push({
          appointment_id: appt.id,
          rating: 4 + (i % 2),
          comment: 'Very helpful and professional service.',
          created_at: appt.start_time_snapshot || now,
          updated_at: appt.start_time_snapshot || now
        });
      }
    }
    
    await queryInterface.bulkInsert('reviews', reviewsData);
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('reviews', null, {});
  }
};

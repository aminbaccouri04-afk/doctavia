'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const now = new Date();
    const [doctors] = await queryInterface.sequelize.query("SELECT id FROM doctors");
    
    if (doctors.length === 0) return;

    const offeringsData = [];
    const offeringTemplates = [
      { name: 'General Consultation', desc: 'Standard check-up and medical advice.', price: 50.00, duration: 30 },
      { name: 'Specialist Review', desc: 'In-depth review of specific medical conditions.', price: 120.00, duration: 45 },
      { name: 'Follow-up Visit', desc: 'Checking progress after treatment.', price: 30.00, duration: 15 },
      { name: 'Emergency Consultation', desc: 'Priority booking for urgent matters.', price: 150.00, duration: 30 },
      { name: 'Diagnostic Results Review', desc: 'Discussing labs, X-rays, or MRI results.', price: 40.00, duration: 20 },
    ];

    for (const doc of doctors) {
      const shuffled = [...offeringTemplates].sort(() => 0.5 - Math.random());
      const selected = shuffled.slice(0, 3 + Math.floor(Math.random() * 2));

      for (const s of selected) {
        offeringsData.push({
          doctorId: doc.id,
          name: s.name,
          description: s.desc,
          price: s.price,
          durationMinutes: s.duration,
          createdAt: now,
          updatedAt: now
        });
      }
    }
    
    await queryInterface.bulkInsert('offerings', offeringsData);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('offerings', null, {});
  }
};

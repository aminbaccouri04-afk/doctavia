'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const [doctors] = await queryInterface.sequelize.query("SELECT d.id, u.email FROM doctors d JOIN users u ON d.user_id = u.id");
    const [specialties] = await queryInterface.sequelize.query("SELECT id, name FROM specialties");

    const docMappings = [
      { email: 'amine@doctavia.com', specs: ['Cardiology', 'General Practice'] },
      { email: 'asma@doctavia.com', specs: ['Orthopedics'] },
      { email: 'fatma@doctavia.com', specs: ['Pediatrics'] },
      { email: 'mariem@doctavia.com', specs: ['Pediatrics', 'Dermatology'] },
      { email: 'mehdi@doctavia.com', specs: ['Neurology'] },
      { email: 'nizar@doctavia.com', specs: ['Ophthalmology'] },
      { email: 'rym@doctavia.com', specs: ['Psychiatry'] },
      { email: 'sami@doctavia.com', specs: ['General Practice'] },
      { email: 'walid@doctavia.com', specs: ['Cardiology'] },
      { email: 'youssef@doctavia.com', specs: ['Dermatology'] },
    ];

    const insertData = [];
    for (const mapping of docMappings) {
      const doctor = doctors.find(d => d.email === mapping.email);
      if (!doctor) continue;

      for (const specName of mapping.specs) {
        const spec = specialties.find(s => s.name === specName);
        if (spec) {
          insertData.push({
            doctor_id: doctor.id,
            specialty_id: spec.id
          });
        }
      }
    }

    if (insertData.length > 0) {
      await queryInterface.bulkInsert('doctor_specialties', insertData);
    }
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('doctor_specialties', null, {});
  }
};

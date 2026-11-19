'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const now = new Date();
    const [users] = await queryInterface.sequelize.query("SELECT id, email FROM users WHERE role = 'doctor' ORDER BY email ASC");
    
    const docDataList = [
      { email: 'amine@doctavia.com', cat: ['Cardiology', 'General Practice'], bio: 'Specialist in cardiovascular health with 15 years experience.' },
      { email: 'asma@doctavia.com', cat: ['Orthopedics'], bio: 'Specialist in bone health, joint replacement, and sports injuries.' },
      { email: 'fatma@doctavia.com', cat: ['Pediatrics'], bio: 'Dedicated to providing the best healthcare for children and neonates.' },
      { email: 'mariem@doctavia.com', cat: ['Pediatrics', 'Dermatology'], bio: 'Double board-certified in pediatrics and dermatology.' },
      { email: 'mehdi@doctavia.com', cat: ['Neurology'], bio: 'Focusing on brain health and nervous system disorders.' },
      { email: 'nizar@doctavia.com', cat: ['Ophthalmology'], bio: 'Specialist in eye surgery and vision care.' },
      { email: 'rym@doctavia.com', cat: ['Psychiatry'], bio: 'Compassionate care for mental health and behavioral disorders.' },
      { email: 'sami@doctavia.com', cat: ['General Practice'], bio: 'Primary care physician focusing on family health and wellness.' },
      { email: 'walid@doctavia.com', cat: ['Cardiology'], bio: 'Expert in interventional cardiology.' },
      { email: 'youssef@doctavia.com', cat: ['Dermatology'], bio: 'Expert in skin conditions and aesthetic medicine.' },
    ];
    
    const doctorsData = [];
    for (const d of docDataList) {
      const user = users.find(u => u.email === d.email);
      if (user) {
        doctorsData.push({
          user_id: user.id,
          experience_years: 5 + Math.floor(Math.random() * 20),
          education: 'Doctorate of Medicine, University of Tunis El Manar',
          bio: 'Specialist committed to providing top-tier patient care and medical excellence.',
          auth_code: '1234',
          created_at: now,
          updated_at: now
        });
      }
    }
    
    await queryInterface.bulkInsert('doctors', doctorsData);
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('doctors', null, {});
  }
};

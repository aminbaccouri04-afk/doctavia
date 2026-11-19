'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const now = new Date();
    const [secretaries] = await queryInterface.sequelize.query("SELECT id, email FROM users WHERE role = 'secretary' ORDER BY email ASC");
    const [doctors] = await queryInterface.sequelize.query('SELECT d.id, u.email FROM doctors d JOIN users u ON d.user_id = u.id ORDER BY u.email ASC');
    
    const secData = [
      { email: 'ahmed@doctavia.com', docIdx: [2, 3, 4] },
      { email: 'mouna@doctavia.com', docIdx: [5, 6, 7, 8, 9] },
      { email: 'sonia@doctavia.com', docIdx: [0, 1] }
    ];
    
    const staffData = [];
    for (const s of secData) {
      const secUser = secretaries.find(u => u.email === s.email);
      if (secUser) {
        for (const idx of s.docIdx) {
           if (doctors[idx]) {
             staffData.push({ user_id: secUser.id, doctor_id: doctors[idx].id, created_at: now, updated_at: now });
           }
        }
      }
    }
    
    await queryInterface.bulkInsert('practice_staff', staffData);
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('practice_staff', null, {});
  }
};

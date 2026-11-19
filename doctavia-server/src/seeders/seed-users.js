'use strict';
const bcrypt = require('bcryptjs');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const hash = await bcrypt.hash('password123', 10);
    const now = new Date();
    
    const doctorEmails = ['amine', 'youssef', 'fatma', 'mehdi', 'asma', 'sami', 'rym', 'nizar', 'mariem', 'walid'].map(n => n + '@doctavia.com');
    const secretaryEmails = ['sonia', 'ahmed', 'mouna'].map(n => n + '@doctavia.com');
    const patientEmails = ['mohamed@gmail.com', 'salma@yahoo.com', 'wassim.c@gmail.com', 'nour.h@gmail.com', 'bilel.d@gmail.com', 'amira@gmail.com', 'fares@gmail.com', 'hela@gmail.com', 'tarek@gmail.com', 'nadia@gmail.com'];
    
    const usersData = [];
    doctorEmails.forEach(email => usersData.push({ email, password: hash, role: 'doctor', created_at: now, updated_at: now }));
    secretaryEmails.forEach(email => usersData.push({ email, password: hash, role: 'secretary', created_at: now, updated_at: now }));
    patientEmails.forEach(email => usersData.push({ email, password: hash, role: 'patient', created_at: now, updated_at: now }));
    
    await queryInterface.bulkInsert('users', usersData);
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('users', null, {});
  }
};

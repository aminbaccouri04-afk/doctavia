'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const now = new Date();
    const [patients] = await queryInterface.sequelize.query("SELECT id, email FROM users WHERE role = 'patient' ORDER BY email ASC");
    const [profiles] = await queryInterface.sequelize.query("SELECT id, account_id, relationship FROM profiles");
    const [futureSlots] = await queryInterface.sequelize.query("SELECT id, start_time, end_time FROM availability_slots WHERE is_booked = false ORDER BY start_time ASC");
    const [pastSlots] = await queryInterface.sequelize.query("SELECT id, start_time, end_time FROM availability_slots WHERE is_booked = true ORDER BY start_time DESC");
    
    const apptsData = [];
    const updatedSlotIds = [];
    
    // Future Appointments (20)
    for (let i = 0; i < 20; i++) {
      const slot = futureSlots[i * 5];
      if (!slot) continue;
      
      const patientUser = patients[i % patients.length];
      const patientProfile = profiles.find(p => p.account_id === patientUser.id && p.relationship === 'Self');
      
      if (patientProfile) {
        apptsData.push({
          slot_id: slot.id,
          patient_profile_id: patientProfile.id,
          booked_by_id: patientUser.id,
          status: 'confirmed',
          start_time_snapshot: slot.start_time,
          end_time_snapshot: slot.end_time,
          created_at: now,
          updated_at: now
        });
        updatedSlotIds.push(slot.id);
      }
    }
    
    // Past Appointments
    let i = 0;
    for (const slot of pastSlots) {
      const patientUser = patients[i % patients.length];
      const patientProfile = profiles.find(p => p.account_id === patientUser.id && p.relationship === 'Self');
      
      if (patientProfile) {
        apptsData.push({
          slot_id: slot.id,
          patient_profile_id: patientProfile.id,
          booked_by_id: patientUser.id,
          status: 'completed',
          start_time_snapshot: slot.start_time,
          end_time_snapshot: slot.end_time,
          created_at: slot.start_time,
          updated_at: slot.start_time
        });
      }
      i++;
    }
    
    await queryInterface.bulkInsert('appointments', apptsData);
    
    if (updatedSlotIds.length > 0) {
      const placeholders = updatedSlotIds.map(() => '?').join(',');
      await queryInterface.sequelize.query(
        `UPDATE availability_slots SET is_booked = true WHERE id IN (${placeholders})`,
        { replacements: updatedSlotIds }
      );
    }
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('appointments', null, {});
  }
};

'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const now = new Date();
    const [users] = await queryInterface.sequelize.query('SELECT id, email, role FROM users');
    
    const docNames = ['Amine Ben Ali', 'Youssef Trabelsi', 'Fatma Gharbi', 'Mehdi Jendoubi', 'Asma Khemiri', 'Sami Bouazizi', 'Rym Riahi', 'Nizar Hadded', 'Mariem Zribi', 'Walid Mansour'];
    const secNames = ['Sonia Secretary', 'Ahmed Secretary', 'Mouna Secretary'];
    const patData = [
      { email: 'mohamed@gmail.com', name: 'Mohamed Yacoubi', dob: '1985-05-12' },
      { email: 'salma@yahoo.com', name: 'Salma Ayari', dob: '1990-08-22' },
      { email: 'wassim.c@gmail.com', name: 'Wassim Cherif', dob: '1975-11-05' },
      { email: 'nour.h@gmail.com', name: 'Nour Hachani', dob: '1960-03-15' },
      { email: 'bilel.d@gmail.com', name: 'Bilel Dridi', dob: '1995-12-25' },
      { email: 'amira@gmail.com', name: 'Amira Othmani', dob: '1988-06-10' },
      { email: 'fares@gmail.com', name: 'Fares Mbarek', dob: '1970-09-30' },
      { email: 'hela@gmail.com', name: 'Hela Saidi', dob: '1992-01-15' },
      { email: 'tarek@gmail.com', name: 'Tarek Dhaouadi', dob: '1955-07-20' },
      { email: 'nadia@gmail.com', name: 'Nadia Boughanmi', dob: '2000-04-12' },
    ];

    const avatars = [
      'Amira', 'Lucas', 'Youssef', 'Emma', 'Noah', 
      'Lina', 'Omar', 'Sofia', 'Ethan', 'Maya'
    ].map(seed => `https://api.dicebear.com/9.x/lorelei/png?seed=${seed}`);

    const profilesData = [];
    let avatarIdx = 0;
    
    for (const user of users) {
      const avatarUrl = avatars[avatarIdx % avatars.length];
      avatarIdx++;

      if (user.role === 'doctor') {
        const name = docNames.find(n => n.toLowerCase().includes(user.email.split('@')[0]));
        profilesData.push({ 
          account_id: user.id, 
          full_name: name || 'Doctor', 
          date_of_birth: '1980-01-01', 
          relationship: 'Self', 
          avatar_url: avatarUrl,
          created_at: now, 
          updated_at: now 
        });
      } else if (user.role === 'secretary') {
        const name = secNames.find(n => n.toLowerCase().includes(user.email.split('@')[0]));
        profilesData.push({ 
          account_id: user.id, 
          full_name: name || 'Secretary', 
          date_of_birth: '1990-01-01', 
          relationship: 'Self', 
          avatar_url: avatarUrl,
          created_at: now, 
          updated_at: now 
        });
      } else if (user.role === 'patient') {
        const p = patData.find(pd => pd.email === user.email);
        if (p) {
          profilesData.push({ 
            account_id: user.id, 
            full_name: p.name, 
            date_of_birth: p.dob, 
            relationship: 'Self', 
            avatar_url: avatarUrl,
            created_at: now, 
            updated_at: now 
          });
          
          // Add family member for some (indices 0, 2, 4, 6, 8)
          const idx = patData.indexOf(p);
          if (idx !== -1 && idx % 2 === 0) {
            profilesData.push({
              account_id: user.id,
              full_name: `Family ${p.name}`,
              date_of_birth: '2015-01-01',
              relationship: idx % 4 === 0 ? 'Child' : 'Parent',
              avatar_url: avatars[(avatarIdx + idx) % avatars.length],
              created_at: now,
              updated_at: now
            });
          }
        }
      }
    }
    
    await queryInterface.bulkInsert('profiles', profilesData);
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('profiles', null, {});
  }
};

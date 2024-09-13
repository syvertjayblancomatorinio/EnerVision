List<Map<String, dynamic>> mockUsers = [
  {
    'username': 'JohnDoe',
    'profile': 'profile_pic_1.png',
    'email': 'johndoe@example.com',
    'password': 'password123',
    'energyRate': 0.12,
    'appliances': [
      {
        'imagePath': 'asset/images/image1.png',
        'name': 'Air Conditioner',
        'wattage': 2000.0,
        'usagePattern': 5
      },
      {
        'imagePath': 'asset/images/image2.png',
        'name': 'Refrigerator',
        'wattage': 150.0,
        'usagePattern': 24
      },
    ],
    'role': 'Admin',
  },
  {
    'username': 'JaneSmith',
    'profile': 'profile_pic_2.png',
    'email': 'janesmith@example.com',
    'password': 'password456',
    'energyRate': 0.15,
    'appliances': [
      {
        'imagePath': 'asset/images/image2.png',
        'name': 'Refrigerator',
        'wattage': 150.0,
        'usagePattern': 24
      },
      {
        'imagePath': 'asset/images/image3.png',
        'name': 'Washing Machine',
        'wattage': 500.0,
        'usagePattern': 1
      },
    ],
    'role': 'User',
  },
  // Add more users as needed
];

// List<Map<String, dynamic>> mockUsers = [
//   {
//     'username': 'JohnDoe',
//     'profile': 'profile_pic_1.png',
//     'email': 'johndoe@example.com',
//     'password': 'password123', // Use plain text or hash for comparison
//     'energyRate': 0.12, // Cost per kWh
//     'appliances': [
//       mockAppliances[0], // Air Conditioner
//       mockAppliances[1], // Refrigerator
//     ],
//     'role': 'User',
//   },
//   {
//     'username': 'JaneSmith',
//     'profile': 'profile_pic_2.png',
//     'email': 'janesmith@example.com',
//     'password': 'password456', // Use plain text or hash for comparison
//     'energyRate': 0.15, // Cost per kWh
//     'appliances': [
//       mockAppliances[1], // Refrigerator
//       mockAppliances[2], // Washing Machine
//     ],
//     'role': 'User',
//   },
//   // Add more users as needed
// ];

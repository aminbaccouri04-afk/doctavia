const express = require('express');
const specialtyController = require('../controllers/controller-specialty');

const router = express.Router();

router.get('/', specialtyController.getSpecialties);

module.exports = router;

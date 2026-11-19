const express = require('express');
const staffController = require('../controllers/controller-staff');
const authMiddleware = require('../middleware/middleware-auth');

const router = express.Router();

router.use(authMiddleware.protect);

router.get('/code', authMiddleware.restrictTo('doctor'), staffController.generateCode);
router.post('/link', authMiddleware.restrictTo('secretary'), staffController.linkSecretary);
router.get('/registry', authMiddleware.restrictTo('secretary'), staffController.getRegistry);

// Doctor only: Manage linked staff
router.get('/members', authMiddleware.restrictTo('doctor'), staffController.getMembers);
router.delete('/members/:id', authMiddleware.restrictTo('doctor'), staffController.removeMember);

module.exports = router;

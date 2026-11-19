const express = require('express');
const analyticsController = require('../controllers/controller-analytics');
const authMiddleware = require('../middleware/middleware-auth');

const router = express.Router();

router.use(authMiddleware.protect);
router.use(authMiddleware.restrictTo('doctor', 'secretary'));

router.get('/', analyticsController.getKPIs);

module.exports = router;

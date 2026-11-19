const express = require('express');
const reviewController = require('../controllers/controller-review');
const authMiddleware = require('../middleware/middleware-auth');

const router = express.Router();

router.use(authMiddleware.protect);
router.use(authMiddleware.restrictTo('patient'));

router.post('/', reviewController.submitReview);

module.exports = router;

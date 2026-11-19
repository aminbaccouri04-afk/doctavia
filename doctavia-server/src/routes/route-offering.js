const express = require('express');
const offeringController = require('../controllers/controller-offering');
const authMiddleware = require('../middleware/middleware-auth');

const router = express.Router();

// All offering management routes require authentication
router.use(authMiddleware.protect);

// Only doctors can manage offerings
router.use(authMiddleware.restrictTo('doctor'));

router
  .route('/')
  .get(offeringController.getMyOfferings)
  .post(offeringController.createOffering);

router
  .route('/:id')
  .patch(offeringController.updateOffering)
  .delete(offeringController.deleteOffering);

module.exports = router;

const express = require('express');
const billingController = require('../controllers/controller-billing');
const authMiddleware = require('../middleware/middleware-auth');

const router = express.Router();

router.use(authMiddleware.protect);

router.get('/invoices', billingController.getMyInvoices);
router.get('/invoices/:id', billingController.getInvoice);
router.post('/invoices/:id/pay', authMiddleware.restrictTo('patient'), billingController.payInvoice);

module.exports = router;

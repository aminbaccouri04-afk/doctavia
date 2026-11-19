const BillingService = require('../services/service-billing');
const { Invoice } = require('../models');
const AppError = require('../utils/util-app-error');

exports.getMyInvoices = async (req, res, next) => {
  try {
    let where = {};
    if (req.user.role === 'patient') {
      // Find invoices for all profiles under this account
      const { Profile } = require('../models');
      const profiles = await Profile.findAll({ where: { accountId: req.user.id } });
      const profileIds = profiles.map(p => p.id);
      where.patientProfileId = profileIds;
    } else if (req.user.role === 'doctor') {
      const { Doctor } = require('../models');
      const doctor = await Doctor.findOne({ where: { userId: req.user.id } });
      where.doctorId = doctor.id;
    }

    const invoices = await Invoice.findAll({ 
      where,
      order: [['issuedAt', 'DESC']]
    });

    res.status(200).json({ status: 'success', results: invoices.length, data: { invoices } });
  } catch (err) {
    next(err);
  }
};

exports.getInvoice = async (req, res, next) => {
  try {
    const invoice = await Invoice.findByPk(req.params.id);
    if (!invoice) throw new AppError('Invoice not found', 404);
    
    res.status(200).json({ status: 'success', data: { invoice } });
  } catch (err) {
    next(err);
  }
};

exports.payInvoice = async (req, res, next) => {
  try {
    const invoice = await Invoice.findByPk(req.params.id);
    if (!invoice) throw new AppError('Invoice not found', 404);

    await invoice.update({ status: 'paid', paidAt: new Date() });
    res.status(200).json({ status: 'success', data: { invoice } });
  } catch (err) {
    next(err);
  }
};

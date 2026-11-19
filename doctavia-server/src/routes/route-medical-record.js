const express = require('express');
const medicalRecordController = require('../controllers/controller-medical-record');
const authMiddleware = require('../middleware/middleware-auth');
const upload = require('../middleware/middleware-upload');

const router = express.Router();

router.use(authMiddleware.protect);

// Secretaries are completely blocked from the Medical Vault as per PRD
router.use((req, res, next) => {
  if (req.user.role === 'secretary') {
    return next(new Error('Secretaries do not have access to clinical files'));
  }
  next();
});

router.post('/:profileId', upload.single('document'), medicalRecordController.uploadRecord);
router.get('/:profileId', medicalRecordController.getRecords);
router.delete('/:id', medicalRecordController.deleteRecord);

module.exports = router;

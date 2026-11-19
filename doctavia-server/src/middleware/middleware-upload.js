const multer = require('multer');
const path = require('path');
const AppError = require('../utils/util-app-error');

/**
 * Storage configuration for clinical documents.
 * Files are stored in src/uploads/medical_records with a timestamp and random suffix.
 */
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'src/uploads/medical_records');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

/**
 * Filter to ensure only PDF or Image files are uploaded.
 */
const fileFilter = (req, file, cb) => {
  const allowedTypes = ['application/pdf', 'image/jpeg', 'image/png'];
  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new AppError('Only PDF, JPEG, and PNG files are allowed', 400), false);
  }
};

const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB limit
  }
});

module.exports = upload;

const express = require('express');
const noteController = require('../controllers/controller-note');
const authMiddleware = require('../middleware/middleware-auth');

const router = express.Router({ mergeParams: true }); // Allows accessing :id from /appointments/:id/notes

router.use(authMiddleware.protect);

// Writing notes: doctors only
// Reading notes: all authenticated roles (content filtered in controller by role)
router.post('/', authMiddleware.restrictTo('doctor'), noteController.addNote);
router.get('/', noteController.getNotes);

module.exports = router;

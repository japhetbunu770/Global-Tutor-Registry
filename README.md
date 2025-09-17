# 🎓 Global Tutor Registry

> A decentralized blockchain-based platform for verified tutor identity and background checking

## 🌟 Overview

The Global Tutor Registry is a smart contract built on the Stacks blockchain that provides a decentralized system for tutor registration, verification, and discovery. Students can confidently hire tutors knowing their qualifications and background have been verified on-chain.

## ✨ Key Features

- 📝 **Tutor Registration**: Complete profile creation with qualifications and subjects
- 🔐 **Background Verification**: Decentralized verification system with document submission
- ⭐ **Rating System**: Student reviews and ratings for tutors
- 🔍 **Subject Discovery**: Find tutors by subject specialization
- 💰 **Transparent Fees**: Clear verification costs and hourly rates
- 🛡️ **Immutable Records**: All verifications and ratings stored on blockchain

## 🚀 Quick Start

### For Tutors

1. **Register Your Profile**
   ```clarity
   (contract-call? .Global-Tutor-Registry register-tutor
     "John Doe"
     "Experienced Math tutor with 5 years of teaching"
     (list "Mathematics" "Calculus" "Algebra")
     u50000000  ;; 50 STX per hour
     "Masters in Mathematics - MIT"
     (list "Certified Math Teacher" "Advanced Calculus Certificate")
     u5)
   ```

2. **Request Verification** 
   ```clarity
   (contract-call? .Global-Tutor-Registry request-verification
     "Degree certificate and background check documents uploaded to IPFS: QmXx...")
   ```

3. **Update Your Profile**
   ```clarity
   (contract-call? .Global-Tutor-Registry update-profile
     "John Doe - Math Expert"
     "Updated bio with recent achievements"
     u60000000)  ;; Updated hourly rate
   ```

### For Students

1. **Find Tutors by Subject**
   ```clarity
   (contract-call? .Global-Tutor-Registry get-tutors-by-subject "Mathematics")
   ```

2. **Check Tutor Details**
   ```clarity
   (contract-call? .Global-Tutor-Registry get-tutor 'SP1XXXXX...)
   ```

3. **Rate Your Tutor**
   ```clarity
   (contract-call? .Global-Tutor-Registry rate-tutor
     'SP1XXXXX...
     u5
     "Excellent tutor! Very patient and knowledgeable")
   ```

## 📊 Contract Functions

### Public Functions

| Function | Description | Parameters |
|----------|-------------|------------|
| `register-tutor` | Register as a new tutor | name, bio, subjects, hourly-rate, education, certifications, experience-years |
| `request-verification` | Submit verification request | documents (IPFS hash) |
| `rate-tutor` | Rate and review a tutor | tutor-principal, rating (1-5), comment |
| `update-profile` | Update tutor profile | name, bio, hourly-rate |

### Read-Only Functions

| Function | Description |
|----------|-------------|
| `get-tutor` | Get tutor profile information |
| `get-tutor-qualifications` | Get tutor's education and certifications |
| `get-tutor-average-rating` | Calculate tutor's average rating |
| `is-tutor-verified` | Check if tutor is verified |
| `get-tutors-by-subject` | Find all tutors for a specific subject |
| `get-total-tutors` | Get total number of registered tutors |

## 💡 Usage Examples

### Searching for Tutors
```clarity
;; Find Math tutors
(contract-call? .Global-Tutor-Registry get-tutors-by-subject "Mathematics")

;; Check if tutor is verified
(contract-call? .Global-Tutor-Registry is-tutor-verified 'SP2XXXXX...)

;; Get tutor's average rating
(contract-call? .Global-Tutor-Registry get-tutor-average-rating 'SP2XXXXX...)
```

### Verification Process
```clarity
;; Current verification fee
(contract-call? .Global-Tutor-Registry get-current-verification-fee)

;; Check verification status
(contract-call? .Global-Tutor-Registry get-verification-request 'SP2XXXXX...)
```

## 🔧 Development

### Prerequisites
- [Clarinet](https://docs.hiro.so/clarinet) installed
- Node.js and npm/yarn

### Setup
```bash
# Clone the repository
git clone https://github.com/japhetbunu770/Global-Tutor-Registry.git
cd Global-Tutor-Registry

# Install dependencies
npm install

# Check contract syntax
clarinet check

# Run tests
clarinet test
```

## 🏗️ Contract Architecture

### Data Structures

- **Tutors Map**: Core tutor profiles with ratings and verification status
- **Qualifications Map**: Education, certifications, and background check status  
- **Ratings Map**: Student reviews indexed by tutor-student pairs
- **Subject Registry**: Efficient subject-based tutor discovery
- **Verification Requests**: Pending verification submissions

### Constants

- **Verification Fee**: 1,000,000 µSTX (1 STX)
- **Rating Range**: 1-5 stars
- **Max Subjects**: 10 per tutor
- **Max Certifications**: 5 per tutor

## 🛡️ Security Features

- ✅ Only contract owner can approve verifications
- ✅ Fee payment required before verification
- ✅ Self-rating prevention
- ✅ Input validation for all parameters
- ✅ Immutable rating and verification history

## 📈 Future Enhancements

- 🔄 Dispute resolution system
- 📅 Session booking and scheduling
- 💬 On-chain messaging between tutors and students
- 🏆 Achievement badges and certifications
- 📊 Advanced analytics and reporting

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- 📧 Email: support@tutorregistry.com
- 💬 Discord: [Join our community](https://discord.gg/tutorregistry)
- 📖 Documentation: [Full API docs](https://docs.tutorregistry.com)

---

**Built with ❤️ on Stacks blockchain** 🟠

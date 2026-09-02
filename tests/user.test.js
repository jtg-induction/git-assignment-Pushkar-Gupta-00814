const userService = require('../src/services/userService');
const User = require('../src/models/user');

// Mock the User model to avoid real DB calls
jest.mock('../src/models/user');

describe('userService', () => {
  afterEach(() => jest.clearAllMocks());

  describe('registerUser()', () => {
    it('should throw 409 if email already exists', async () => {
      User.findOne.mockResolvedValue({ email: 'exists@test.com' });
      await expect(userService.registerUser({
        name: 'Test', email: 'exists@test.com', password: 'password123',
      })).rejects.toMatchObject({ statusCode: 409 });
    });

    it('should create a new user if email is unique', async () => {
      User.findOne.mockResolvedValue(null);
      const mockSave = jest.fn().mockResolvedValue(true);
      const mockUser = {
        name: 'New User',
        email: 'new@test.com',
        save: mockSave,
        toPublic: () => ({ name: 'New User', email: 'new@test.com', role: 'customer' }),
      };
      User.mockImplementation(() => mockUser);
      const result = await userService.registerUser({ name: 'New User', email: 'new@test.com', password: 'password123' });
      expect(mockSave).toHaveBeenCalledTimes(1);
      expect(result.email).toBe('new@test.com');
    });
  });

  describe('loginUser()', () => {
    it('should throw 401 for non-existent user', async () => {
      User.findOne.mockReturnValue({ select: jest.fn().mockResolvedValue(null) });
      await expect(userService.loginUser('ghost@test.com', 'password')).rejects.toMatchObject({ statusCode: 401 });
    });

    it('should throw 401 for wrong password', async () => {
      const mockUser = {
        _id: 'user123',
        role: 'customer',
        comparePassword: jest.fn().mockResolvedValue(false),
        lastLogin: null,
        save: jest.fn(),
      };
      User.findOne.mockReturnValue({ select: jest.fn().mockResolvedValue(mockUser) });
      await expect(userService.loginUser('test@test.com', 'wrongpassword')).rejects.toMatchObject({ statusCode: 401 });
    });
  });
});

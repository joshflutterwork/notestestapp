import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import { UnauthorizedException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';

describe('AuthService', () => {
  let authService: AuthService;
  let usersService: Partial<Record<keyof UsersService, jest.Mock>>;
  let jwtService: Partial<Record<keyof JwtService, jest.Mock>>;

  const mockUser = {
    id: 'user-uuid-123',
    email: 'test@example.com',
    password: '',
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  beforeEach(async () => {
    // Hash a real password for comparison tests
    mockUser.password = await bcrypt.hash('password123', 10);

    usersService = {
      findByEmail: jest.fn(),
      create: jest.fn(),
      findById: jest.fn(),
    };

    jwtService = {
      sign: jest.fn().mockReturnValue('mock-jwt-token'),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: UsersService, useValue: usersService },
        { provide: JwtService, useValue: jwtService },
      ],
    }).compile();

    authService = module.get<AuthService>(AuthService);
  });

  describe('validateUser', () => {
    it('should return user data without password when credentials are valid', async () => {
      usersService.findByEmail!.mockResolvedValue(mockUser);

      const result = await authService.validateUser('test@example.com', 'password123');

      expect(result).toBeDefined();
      expect(result.email).toBe('test@example.com');
      expect(result.id).toBe('user-uuid-123');
      expect(result.password).toBeUndefined();
    });

    it('should return null when user is not found', async () => {
      usersService.findByEmail!.mockResolvedValue(null);

      const result = await authService.validateUser('notfound@example.com', 'password123');

      expect(result).toBeNull();
    });

    it('should return null when password is incorrect', async () => {
      usersService.findByEmail!.mockResolvedValue(mockUser);

      const result = await authService.validateUser('test@example.com', 'wrongpassword');

      expect(result).toBeNull();
    });
  });

  describe('login', () => {
    it('should return access_token and user data on valid login', async () => {
      usersService.findByEmail!.mockResolvedValue(mockUser);

      const result = await authService.login({
        email: 'test@example.com',
        password: 'password123',
      });

      expect(result).toHaveProperty('access_token', 'mock-jwt-token');
      expect(result).toHaveProperty('user');
      expect(result.user).toEqual({
        id: 'user-uuid-123',
        email: 'test@example.com',
      });
      expect(jwtService.sign).toHaveBeenCalledWith({
        email: 'test@example.com',
        sub: 'user-uuid-123',
      });
    });

    it('should throw UnauthorizedException on invalid credentials', async () => {
      usersService.findByEmail!.mockResolvedValue(null);

      await expect(
        authService.login({
          email: 'wrong@example.com',
          password: 'wrongpassword',
        }),
      ).rejects.toThrow(UnauthorizedException);
    });
  });

  describe('register', () => {
    it('should return access_token and user data after registration', async () => {
      const createdUser = {
        id: 'new-user-uuid',
        email: 'newuser@example.com',
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      usersService.create!.mockResolvedValue(createdUser);

      const result = await authService.register({
        email: 'newuser@example.com',
        password: 'password123',
      });

      expect(result).toHaveProperty('access_token', 'mock-jwt-token');
      expect(result.user).toEqual({
        id: 'new-user-uuid',
        email: 'newuser@example.com',
      });
      expect(jwtService.sign).toHaveBeenCalledWith({
        email: 'newuser@example.com',
        sub: 'new-user-uuid',
      });
    });
  });

  describe('logout', () => {
    it('should return success message', async () => {
      const result = await authService.logout();

      expect(result).toEqual({ message: 'Successfully logged out' });
    });
  });
});

import { Test, TestingModule } from '@nestjs/testing';
import { NotesService } from './notes.service';
import { PrismaService } from '../prisma/prisma.service';
import { NotFoundException } from '@nestjs/common';

describe('NotesService', () => {
  let notesService: NotesService;
  let prisma: {
    note: {
      findMany: jest.Mock;
      findFirst: jest.Mock;
      create: jest.Mock;
      update: jest.Mock;
      delete: jest.Mock;
    };
  };

  const userId = 'user-uuid-123';
  const otherUserId = 'other-user-uuid';

  const mockNote = {
    id: 'note-uuid-1',
    title: 'Test Note',
    content: 'Test content',
    userId: userId,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  const mockNote2 = {
    id: 'note-uuid-2',
    title: 'Second Note',
    content: 'Second content',
    userId: userId,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  beforeEach(async () => {
    prisma = {
      note: {
        findMany: jest.fn(),
        findFirst: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
        delete: jest.fn(),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        NotesService,
        { provide: PrismaService, useValue: prisma },
      ],
    }).compile();

    notesService = module.get<NotesService>(NotesService);
  });

  describe('findAll', () => {
    it('should return all notes for a given user', async () => {
      prisma.note.findMany.mockResolvedValue([mockNote, mockNote2]);

      const result = await notesService.findAll(userId);

      expect(result).toHaveLength(2);
      expect(prisma.note.findMany).toHaveBeenCalledWith({
        where: { userId: userId },
        orderBy: { createdAt: 'desc' },
      });
    });

    it('should return empty array when user has no notes', async () => {
      prisma.note.findMany.mockResolvedValue([]);

      const result = await notesService.findAll(userId);

      expect(result).toHaveLength(0);
    });
  });

  describe('findOne', () => {
    it('should return a note when found for the correct user', async () => {
      prisma.note.findFirst.mockResolvedValue(mockNote);

      const result = await notesService.findOne('note-uuid-1', userId);

      expect(result).toEqual(mockNote);
      expect(prisma.note.findFirst).toHaveBeenCalledWith({
        where: { id: 'note-uuid-1', userId: userId },
      });
    });

    it('should throw NotFoundException when note does not exist', async () => {
      prisma.note.findFirst.mockResolvedValue(null);

      await expect(
        notesService.findOne('nonexistent-id', userId),
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw NotFoundException when note belongs to another user', async () => {
      prisma.note.findFirst.mockResolvedValue(null);

      await expect(
        notesService.findOne('note-uuid-1', otherUserId),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('create', () => {
    it('should create and return a new note', async () => {
      const createDto = { title: 'New Note', content: 'New content' };
      const createdNote = { ...mockNote, ...createDto };
      prisma.note.create.mockResolvedValue(createdNote);

      const result = await notesService.create(createDto, userId);

      expect(result.title).toBe('New Note');
      expect(result.content).toBe('New content');
      expect(prisma.note.create).toHaveBeenCalledWith({
        data: {
          title: 'New Note',
          content: 'New content',
          userId: userId,
        },
      });
    });
  });

  describe('update', () => {
    it('should update and return the note', async () => {
      const updateDto = { title: 'Updated Title' };
      prisma.note.findFirst.mockResolvedValue(mockNote);
      prisma.note.update.mockResolvedValue({ ...mockNote, ...updateDto });

      const result = await notesService.update('note-uuid-1', updateDto, userId);

      expect(result.title).toBe('Updated Title');
      expect(prisma.note.findFirst).toHaveBeenCalledWith({
        where: { id: 'note-uuid-1', userId: userId },
      });
      expect(prisma.note.update).toHaveBeenCalledWith({
        where: { id: 'note-uuid-1' },
        data: updateDto,
      });
    });

    it('should throw NotFoundException when updating a non-existent note', async () => {
      prisma.note.findFirst.mockResolvedValue(null);

      await expect(
        notesService.update('nonexistent-id', { title: 'Updated' }, userId),
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw NotFoundException when updating another user note', async () => {
      prisma.note.findFirst.mockResolvedValue(null);

      await expect(
        notesService.update('note-uuid-1', { title: 'Hacked' }, otherUserId),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('remove', () => {
    it('should delete the note and return success message', async () => {
      prisma.note.findFirst.mockResolvedValue(mockNote);
      prisma.note.delete.mockResolvedValue(mockNote);

      const result = await notesService.remove('note-uuid-1', userId);

      expect(result).toEqual({ message: 'Note deleted successfully' });
      expect(prisma.note.delete).toHaveBeenCalledWith({
        where: { id: 'note-uuid-1' },
      });
    });

    it('should throw NotFoundException when deleting a non-existent note', async () => {
      prisma.note.findFirst.mockResolvedValue(null);

      await expect(
        notesService.remove('nonexistent-id', userId),
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw NotFoundException when deleting another user note', async () => {
      prisma.note.findFirst.mockResolvedValue(null);

      await expect(
        notesService.remove('note-uuid-1', otherUserId),
      ).rejects.toThrow(NotFoundException);
    });
  });
});

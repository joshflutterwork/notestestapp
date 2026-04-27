import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateNoteDto } from './dto/create-note.dto';
import { UpdateNoteDto } from './dto/update-note.dto';

@Injectable()
export class NotesService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(userId: string) {
    return this.prisma.note.findMany({
      where: {
        userId: userId,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async findOne(id: string, userId: string) {
    const note = await this.prisma.note.findFirst({
      where: {
        id: id,
        userId: userId,
      },
    });

    if (!note) {
      throw new NotFoundException('Note not found');
    }

    return note;
  }

  async create(createNoteDto: CreateNoteDto, userId: string) {
    return this.prisma.note.create({
      data: {
        title: createNoteDto.title,
        content: createNoteDto.content,
        userId: userId,
      },
    });
  }

  async update(id: string, updateNoteDto: UpdateNoteDto, userId: string) {
    const note = await this.prisma.note.findFirst({
      where: {
        id: id,
        userId: userId,
      },
    });

    if (!note) {
      throw new NotFoundException('Note not found');
    }

    return this.prisma.note.update({
      where: {
        id: id,
      },
      data: updateNoteDto,
    });
  }

  async remove(id: string, userId: string) {
    const note = await this.prisma.note.findFirst({
      where: {
        id: id,
        userId: userId,
      },
    });

    if (!note) {
      throw new NotFoundException('Note not found');
    }

    await this.prisma.note.delete({
      where: {
        id: id,
      },
    });

    return { message: 'Note deleted successfully' };
  }
}
import { IsNotEmpty, IsString, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateNoteDto {
  @ApiProperty({
    example: 'My First Note',
    description: 'Title of the note',
    minLength: 1,
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(1)
  title: string;

  @ApiProperty({
    example: 'This is the content of my first note. It can contain any text.',
    description: 'Content of the note',
  })
  @IsString()
  @IsNotEmpty()
  content: string;
}
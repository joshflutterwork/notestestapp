import { IsString, IsNotEmpty, MinLength, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateNoteDto {
  @ApiProperty({
    example: 'Updated Note Title',
    description: 'Updated title of the note',
    required: false,
    minLength: 1,
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(1)
  @IsOptional()
  title?: string;

  @ApiProperty({
    example: 'This is the updated content of the note.',
    description: 'Updated content of the note',
    required: false,
  })
  @IsString()
  @IsNotEmpty()
  @IsOptional()
  content?: string;
}
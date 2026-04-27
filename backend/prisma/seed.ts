import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('Starting database seed...');

  const hashedPassword = await bcrypt.hash('password123', 10);

  const user = await prisma.user.upsert({
    where: { email: 'test@example.com' },
    update: {},
    create: {
      email: 'test@example.com',
      password: hashedPassword,
    },
  });

  console.log('Created user:', user);

  // Clean up existing notes for this user to make seed idempotent
  await prisma.note.deleteMany({
    where: { userId: user.id },
  });

  console.log('Cleaned up existing notes for test user');

  const note1 = await prisma.note.create({
    data: {
      title: 'First Note',
      content: 'This is the content of the first note',
      userId: user.id,
    },
  });

  console.log('Created note:', note1);

  const note2 = await prisma.note.create({
    data: {
      title: 'Second Note',
      content: 'This is the content of the second note',
      userId: user.id,
    },
  });

  console.log('Created note:', note2);

  console.log('Database seed completed successfully!');
}

main()
  .catch((e) => {
    console.error('Error during database seed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
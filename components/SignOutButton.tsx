"use client";
import { signOut } from 'next-auth/react';

export function SignOutButton() {
  return (
    <button className="text-sm font-medium text-red-600 hover:text-red-700" onClick={() => signOut({ callbackUrl: '/' })}>
      Sign out
    </button>
  );
}
import { ButtonHTMLAttributes } from 'react';
import cn from 'classnames';

type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: 'primary' | 'secondary' | 'ghost';
};

export function Button({ className, variant = 'primary', ...props }: ButtonProps) {
  const styles = {
    primary: 'btn-primary',
    secondary: 'inline-flex items-center rounded-md border border-gray-300 px-4 py-2 font-medium hover:bg-gray-50',
    ghost: 'inline-flex items-center rounded-md px-4 py-2 hover:bg-gray-50',
  }[variant];
  return <button className={cn(styles, className)} {...props} />;
}
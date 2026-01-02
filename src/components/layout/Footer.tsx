import { Link } from 'react-router-dom';
import { Instagram, Mail } from 'lucide-react';
import { Button } from '@/components/ui/button';

export default function Footer() {
  return (
    <footer className="border-t border-border py-8 mt-12">
      <div className="container">
        <div className="flex flex-col md:flex-row items-center justify-between gap-6">
          <p className="text-sm text-muted-foreground">
            © 2024 SHOP SMART. All rights reserved.
          </p>
          
          <div className="flex items-center gap-6">
            <Link to="/products" className="text-sm text-muted-foreground hover:text-foreground">
              Shop
            </Link>
            <Link to="/cart" className="text-sm text-muted-foreground hover:text-foreground">
              Cart
            </Link>
            <Link to="/orders" className="text-sm text-muted-foreground hover:text-foreground">
              Orders
            </Link>
          </div>

          <div className="flex items-center gap-3">
            <Button variant="outline" size="sm" asChild>
              <a href="mailto:contact@shopsmart.com">
                <Mail className="h-4 w-4 mr-2" />
                Contact
              </a>
            </Button>
            <Button variant="outline" size="icon" asChild>
              <a href="https://instagram.com" target="_blank" rel="noopener noreferrer">
                <Instagram className="h-4 w-4" />
              </a>
            </Button>
          </div>
        </div>
      </div>
    </footer>
  );
}

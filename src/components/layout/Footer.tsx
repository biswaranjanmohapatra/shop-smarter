import { Link } from 'react-router-dom';
import { Instagram, Facebook, Twitter } from 'lucide-react';

export default function Footer() {
  const scrollToTop = () => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  return (
    <footer className="mt-12">
      {/* Back to Top */}
      <button
        onClick={scrollToTop}
        className="w-full bg-muted/80 hover:bg-muted py-3 text-sm text-foreground transition-colors"
      >
        Back to top
      </button>

      {/* Main Footer Links */}
      <div className="bg-slate-800 py-10">
        <div className="container">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            {/* Get to Know Us */}
            <div>
              <h3 className="text-white font-semibold mb-4">Get to Know Us</h3>
              <ul className="space-y-2">
                <li>
                  <Link to="/about" className="text-slate-300 hover:text-white text-sm transition-colors">
                    About Shop Smart
                  </Link>
                </li>
                <li>
                  <Link to="/careers" className="text-slate-300 hover:text-white text-sm transition-colors">
                    Careers
                  </Link>
                </li>
                <li>
                  <Link to="/press" className="text-slate-300 hover:text-white text-sm transition-colors">
                    Press Releases
                  </Link>
                </li>
              </ul>
            </div>

            {/* Connect with Us */}
            <div>
              <h3 className="text-white font-semibold mb-4">Connect with Us</h3>
              <ul className="space-y-2">
                <li>
                  <a
                    href="https://facebook.com"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-slate-300 hover:text-white text-sm transition-colors flex items-center gap-2"
                  >
                    <Facebook className="h-4 w-4" />
                    Facebook
                  </a>
                </li>
                <li>
                  <a
                    href="https://twitter.com"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-slate-300 hover:text-white text-sm transition-colors flex items-center gap-2"
                  >
                    <Twitter className="h-4 w-4" />
                    Twitter
                  </a>
                </li>
                <li>
                  <a
                    href="https://instagram.com"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-slate-300 hover:text-white text-sm transition-colors flex items-center gap-2"
                  >
                    <Instagram className="h-4 w-4" />
                    Instagram
                  </a>
                </li>
              </ul>
            </div>

            {/* Shop with Us */}
            <div>
              <h3 className="text-white font-semibold mb-4">Shop with Us</h3>
              <ul className="space-y-2">
                <li>
                  <Link to="/products" className="text-slate-300 hover:text-white text-sm transition-colors">
                    All Products
                  </Link>
                </li>
                <li>
                  <Link to="/products?category=Clothing" className="text-slate-300 hover:text-white text-sm transition-colors">
                    Clothing
                  </Link>
                </li>
                <li>
                  <Link to="/products?category=Electronics" className="text-slate-300 hover:text-white text-sm transition-colors">
                    Electronics
                  </Link>
                </li>
                <li>
                  <Link to="/products?category=Accessories" className="text-slate-300 hover:text-white text-sm transition-colors">
                    Accessories
                  </Link>
                </li>
              </ul>
            </div>

            {/* Let Us Help You */}
            <div>
              <h3 className="text-white font-semibold mb-4">Let Us Help You</h3>
              <ul className="space-y-2">
                <li>
                  <Link to="/orders" className="text-slate-300 hover:text-white text-sm transition-colors">
                    Your Account
                  </Link>
                </li>
                <li>
                  <Link to="/orders" className="text-slate-300 hover:text-white text-sm transition-colors">
                    Your Orders
                  </Link>
                </li>
                <li>
                  <Link to="/cart" className="text-slate-300 hover:text-white text-sm transition-colors">
                    Your Cart
                  </Link>
                </li>
                <li>
                  <a
                    href="mailto:help@shopsmart.com"
                    className="text-slate-300 hover:text-white text-sm transition-colors"
                  >
                    Help
                  </a>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>

      {/* Bottom Bar */}
      <div className="bg-slate-900 py-6">
        <div className="container">
          <div className="flex flex-col items-center gap-4">
            <Link to="/" className="text-xl font-bold text-white tracking-tight">
              SHOP SMART
            </Link>
            <p className="text-slate-400 text-xs">
              © 2024 Shop Smart. All rights reserved.
            </p>
          </div>
        </div>
      </div>
    </footer>
  );
}

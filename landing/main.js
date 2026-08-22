document.addEventListener('DOMContentLoaded', () => {
  const navToggle = document.getElementById('navToggle');
  const navLinks = document.getElementById('navLinks');

  if (navToggle && navLinks) {
    navToggle.addEventListener('click', () => {
      const isOpen = navLinks.classList.toggle('open');
      navToggle.setAttribute('aria-expanded', String(isOpen));
      document.body.style.overflow = isOpen ? 'hidden' : '';
    });

    // Fermer le menu au clic sur un lien
    navLinks.querySelectorAll('a').forEach(link => {
      link.addEventListener('click', () => {
        navLinks.classList.remove('open');
        navToggle.setAttribute('aria-expanded', 'false');
        document.body.style.overflow = '';
      });
    });
  }

  // Active nav state on scroll
  const sections = document.querySelectorAll('section[id]');
  const navItems = document.querySelectorAll('.nav-links a[href^="#"]');

  if ('IntersectionObserver' in window) {
    const observer = new IntersectionObserver(
      entries => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            const id = entry.target.id;
            navItems.forEach(item => {
              item.classList.toggle('active', item.getAttribute('href') === `#${id}`);
            });
          }
        });
      },
      { threshold: 0.3, rootMargin: '-72px 0px 0px 0px' }
    );

    sections.forEach(section => observer.observe(section));
  }

  // Testimonials carousel
  const carousel = document.querySelector('[data-carousel]');
  if (carousel) {
    const track = carousel.querySelector('.testimonials-track');
    const slides = Array.from(carousel.querySelectorAll('.testimonial-slide'));
    const dotsContainer = carousel.querySelector('.carousel-dots');
    let currentIndex = 0;
    let autoplayInterval;
    let slidesVisible = 3;

    function getSlidesVisible() {
      if (window.innerWidth <= 768) return 1;
      if (window.innerWidth <= 1024) return 2;
      return 3;
    }

    function updateSlidesVisible() {
      slidesVisible = getSlidesVisible();
      goToSlide(currentIndex);
    }

    function createDots() {
      if (!dotsContainer) return;
      dotsContainer.innerHTML = '';
      const totalPages = slides.length;
      for (let i = 0; i < totalPages; i++) {
        const dot = document.createElement('button');
        dot.className = 'carousel-dot';
        dot.setAttribute('aria-label', `Témoignage ${i + 1}`);
        dot.addEventListener('click', () => {
          goToSlide(i);
          resetAutoplay();
        });
        dotsContainer.appendChild(dot);
      }
    }

    function updateDots() {
      const dots = dotsContainer?.querySelectorAll('.carousel-dot');
      if (!dots) return;
      dots.forEach((dot, index) => {
        dot.classList.toggle('active', index === currentIndex);
      });
    }

    function goToSlide(index) {
      const maxIndex = slides.length - slidesVisible;
      currentIndex = Math.max(0, Math.min(index, maxIndex));
      const slideWidth = slides[0].getBoundingClientRect().width;
      const gap = parseInt(getComputedStyle(track).gap) || 0;
      const offset = currentIndex * (slideWidth + gap);
      track.style.transform = `translateX(-${offset}px)`;
      updateDots();
    }

    function nextSlide() {
      const maxIndex = slides.length - slidesVisible;
      currentIndex = currentIndex >= maxIndex ? 0 : currentIndex + 1;
      goToSlide(currentIndex);
    }

    function startAutoplay() {
      autoplayInterval = setInterval(nextSlide, 5000);
    }

    function resetAutoplay() {
      clearInterval(autoplayInterval);
      startAutoplay();
    }

    function stopAutoplay() {
      clearInterval(autoplayInterval);
    }

    if (track && slides.length) {
      createDots();
      updateSlidesVisible();
      startAutoplay();

      track.addEventListener('mouseenter', stopAutoplay);
      track.addEventListener('mouseleave', startAutoplay);

      window.addEventListener('resize', () => {
        updateSlidesVisible();
      });

      // Simple touch swipe
      let touchStartX = 0;
      let touchEndX = 0;
      track.addEventListener('touchstart', e => {
        touchStartX = e.changedTouches[0].screenX;
      }, { passive: true });

      track.addEventListener('touchend', e => {
        touchEndX = e.changedTouches[0].screenX;
        const diff = touchStartX - touchEndX;
        if (Math.abs(diff) > 40) {
          const maxIndex = slides.length - slidesVisible;
          if (diff > 0) {
            goToSlide(Math.min(currentIndex + 1, maxIndex));
          } else {
            goToSlide(Math.max(currentIndex - 1, 0));
          }
          resetAutoplay();
        }
      }, { passive: true });
    }
  }

  // Simple contact form handler (no backend yet)
  const form = document.querySelector('.contact-form');
  if (form) {
    form.addEventListener('submit', event => {
      event.preventDefault();
      const btn = form.querySelector('button[type="submit"]');
      const originalText = btn.textContent;

      btn.textContent = 'Message envoyé !';
      btn.disabled = true;

      setTimeout(() => {
        btn.textContent = originalText;
        btn.disabled = false;
        form.reset();
      }, 2500);
    });
  }
});

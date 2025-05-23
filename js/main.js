$(document).ready(function() {
  // Add floating elements to the body
  function addFloatingElements() {
    for (let i = 0; i < 3; i++) {
      $('body').append('<div class="floating-element"></div>');
    }
  }
  
  let carouselsToUpdateOnLoad = [];

  function renderCarousel(cardsData, containerSelector, leftArrow, rightArrow) {
    let current = 0;
    const container = $(containerSelector);
    let detailsOpen = false;
    
    function renderCards() {
      container.empty();
      const numCards = cardsData.length;
      if (numCards === 0) return;

      // Determine indices for prev, current, next cards, handling wrap-around
      const prevIndex = (current - 1 + numCards) % numCards;
      const nextIndex = (current + 1) % numCards;

      // Create a small array of cards to display: previous, current, next
      // This helps with the cycling effect and managing active/side classes.
      // For carousels with 1 or 2 items, adjust logic.
      let cardsToRenderInfo = [];
      if (numCards === 1) {
        cardsToRenderInfo.push({ data: cardsData[current], originalIndex: current, displayClass: 'active' });
      } else if (numCards === 2) {
        // Always show both. 'current' is active, the other is 'side'.
        cardsToRenderInfo.push({ data: cardsData[current], originalIndex: current, displayClass: 'active' });
        cardsToRenderInfo.push({ data: cardsData[nextIndex], originalIndex: nextIndex, displayClass: 'side' });
        // To maintain visual consistency, we might need to decide which side the 'other' card is on.
        // This simplified version just makes the 'next' one a generic 'side'.
      } else { // 3 or more cards
        cardsToRenderInfo.push({ data: cardsData[prevIndex], originalIndex: prevIndex, displayClass: 'side left' });
        cardsToRenderInfo.push({ data: cardsData[current], originalIndex: current, displayClass: 'active' });
        cardsToRenderInfo.push({ data: cardsData[nextIndex], originalIndex: nextIndex, displayClass: 'side' });
      }

      cardsToRenderInfo.forEach(cardInfo => {
        let card = $('<div class="card"></div>');
        card.addClass(cardInfo.displayClass);
        
        card.append(`<img src="${cardInfo.data.image}" alt="${cardInfo.data.title}">`);
        card.append(`<h3>${cardInfo.data.title}</h3>`);
        if (cardInfo.data.purpose) card.append(`<p>${cardInfo.data.purpose}</p>`);
        if (cardInfo.data.hypothesis) card.append(`<p><b>Hypothesis:</b> ${cardInfo.data.hypothesis}</p>`);
        let details = $('<details></details>');
        let summaryText = cardInfo.data.responsibilities ? 'Details & Responsibilities' : 'Details & Results';
        details.append(`<summary>${summaryText}</summary>`);
        if (cardInfo.data.details) details.append(`<p>${cardInfo.data.details}</p>`);
        if (cardInfo.data.responsibilities) details.append(`<p><b>Responsibilities:</b> ${cardInfo.data.responsibilities}</p>`);
        if (cardInfo.data.results) details.append(`<p><b>Results:</b> ${cardInfo.data.results}</p>`);
        if (card.hasClass('active') && detailsOpen) {
          details.prop('open', true);
          card.addClass('expanded');
        }
        // If this is the active card add toggle listener to set global state
        if (card.hasClass('active')) {
          details.on('toggle', function() {
            detailsOpen = this.open;
            card.toggleClass('expanded', this.open);
            updateCarouselPosition();
          });
        }
        card.append(details);
        container.append(card);
      });
    }
    
    function updateCarouselPositionAndClasses() {
      renderCards();
      updateCarouselPosition();
    }

    function updateCarouselPosition() {
      const cards = container.find('.card');
      if (cards.length === 0) return;

      const offset = computeActiveCenteredOffset();
      container.css('transform', `translateX(${offset}px)`);
    }

    function computeActiveCenteredOffset() {
      const cards = container.find('.card');
      const activeCard = cards.filter('.active');
      if (!activeCard.length) return 0;

      const gap = cards.length <= 1 ? 0 : getGapInPixels();

      // Sum widths (plus gaps) of all cards BEFORE the active card
      let distanceToActiveStart = 0;
      cards.each(function() {
        if (this === activeCard[0]) return false; // break
        distanceToActiveStart += $(this).outerWidth(false) + gap;
      });

      const activeWidth = activeCard.outerWidth(false);
      const activeCenterPos = distanceToActiveStart + (activeWidth / 2);

      const carouselViewportWidth = container.parent().width();
      return (carouselViewportWidth / 2) - activeCenterPos;
    }
    
    // --- Smooth sliding animation helpers ---
    let isAnimating = false;
    let fallbackTimer = null;
    let transitionEndHandler = null;

    function getGapInPixels() {
      let gap = parseFloat(container.css('gap'));
      return isNaN(gap) ? 0 : gap;
    }

    function getCardWidth() {
      const firstCard = container.find('.card').first();
      return firstCard.length ? firstCard.outerWidth(false) : 0; // width without margin
    }

    function getCenteredOffset() {
      return computeActiveCenteredOffset();
    }

    function slide(direction) {
      if (cardsData.length <= 1) return;

      // If an animation is already running, finish it instantly
      if (isAnimating) {
        finishCurrentAnimation();
      }

      isAnimating = true;

      // Safety fallback in case transitionend doesn't fire (e.g. user tab switch)
      fallbackTimer = setTimeout(() => {
        finishCurrentAnimation();
      }, 800);

      // 1. Update the logical index first
      if (direction === 'right') {
        current = (current + 1) % cardsData.length;
      } else {
        current = (current - 1 + cardsData.length) % cardsData.length;
      }

      // 2. Re-render cards for the new logical state (prev, active, next)
      renderCards();

      const shift = getCardWidth() + getGapInPixels();
      const centerOffset = getCenteredOffset();

      // 3. Jump instantly to a start position where the OLD centre card is still centred
      const startOffset = direction === 'right'
        ? centerOffset + shift
        : centerOffset - shift;

      container.css({ transition: 'none', transform: `translateX(${startOffset}px)` });

      // Force reflow so the browser registers the transform without transition
      void container[0].offsetWidth;

      // 4. Animate to the real centred position for the new state
      container.css({ transition: 'transform 0.6s cubic-bezier(0.23, 1, 0.32, 1)', transform: `translateX(${centerOffset}px)` });

      transitionEndHandler = function(e) {
        if (e.target !== this) return;
        finishCurrentAnimation();
      };
      container.one('transitionend', transitionEndHandler);
    }

    function finishCurrentAnimation() {
      if (!isAnimating) return;
      if (fallbackTimer) {
        clearTimeout(fallbackTimer);
        fallbackTimer = null;
      }
      container.off('transitionend', transitionEndHandler);
      container.css('transition', 'none');
      updateCarouselPosition(); // snap to final centered position for current state
      void container[0].offsetWidth; // reflow
      container.css('transition', 'transform 0.6s cubic-bezier(0.23, 1, 0.32, 1)');
      isAnimating = false;
    }

    $(leftArrow).off('click').on('click', function() { slide('left'); });
    $(rightArrow).off('click').on('click', function() { slide('right'); });

    $(document).on('keydown', function(e) {
      if ($(e.target).is('input, textarea, details, summary')) return;
      if(container.is(":visible")){
        if (e.key === 'ArrowLeft') slide('left');
        if (e.key === 'ArrowRight') slide('right');
      }
    });
    
    $(window).on('resize', function() {
      updateCarouselPosition();
    });
    
    renderCards();
    updateCarouselPosition();
    carouselsToUpdateOnLoad.push(updateCarouselPosition);
  }

  $.getJSON('data/all_data.json', function(data) {
    $('#intro p').html(data.intro);
    $('#recommendation blockquote').html(data.recommendation.replace(/\n/g, '<br><br>'));
    renderCarousel(data.projects, '#projects-scroll', '#projects-left', '#projects-right');
    renderCarousel(data.experiments, '#experiments-scroll', '#experiments-left', '#experiments-right');
    
    if (document.readyState === 'complete') {
      carouselsToUpdateOnLoad.forEach(fn => fn());
      carouselsToUpdateOnLoad = [];
    }

  }).fail(function() {
    console.error('Failed to load data. Trying fallback...');
    $.getJSON('data/projects.json', function(projects) {
      renderCarousel(projects, '#projects-scroll', '#projects-left', '#projects-right');
    });
    $.getJSON('data/experiments.json', function(experiments) {
      renderCarousel(experiments, '#experiments-scroll', '#experiments-left', '#experiments-right');
    });
  });
  
  addFloatingElements();
  $('html').css('scroll-behavior', 'smooth');

  $(window).on('load', function() {
    carouselsToUpdateOnLoad.forEach(fn => fn());
    carouselsToUpdateOnLoad = [];
  });
});
  
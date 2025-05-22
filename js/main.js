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

      const cardElementWidth = cards.first().outerWidth(false); // Use outerWidth(false) for width without margin
      let gapInPixels = parseFloat(container.css('gap'));
      if (isNaN(gapInPixels) || cards.length <= 1) { // No gap if 1 card or gap is not a number
        gapInPixels = 0;
      }
      
      // Total width of the visible cards block
      const cardsBlockWidth = (cardElementWidth * cards.length) + (gapInPixels * (cards.length - 1));
      const carouselViewportWidth = container.parent().width();
      
      // Center the block of cards
      const offset = (carouselViewportWidth / 2) - (cardsBlockWidth / 2);

      container.css('transform', `translateX(${offset}px)`);
    }
    
    function goLeft() {
      current = (current - 1 + cardsData.length) % cardsData.length;
      updateCarouselPositionAndClasses();
    }
    
    function goRight() {
      current = (current + 1) % cardsData.length;
      updateCarouselPositionAndClasses();
    }
    
    $(leftArrow).off('click').on('click', goLeft);
    $(rightArrow).off('click').on('click', goRight);
    
    $(document).on('keydown', function(e) {
      if ($(e.target).is('input, textarea, details, summary')) return;
      if(container.is(":visible")){
        if (e.key === 'ArrowLeft') goLeft();
        if (e.key === 'ArrowRight') goRight();
      }
    });
    
    $(window).on('resize', function() {
      updateCarouselPosition();
    });
    
    renderCards();
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
  
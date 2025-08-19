// script.js
// This file dynamically constructs the portfolio site based on the embedded
// JSON data. It creates cards for projects and experiments, handles the
// show/hide functionality for details and the recommendation letter, and
// populates the introduction section.

/**
 * Utility function to truncate text at a word boundary. If the text is
 * shorter than the limit, it is returned unchanged. Otherwise an ellipsis
 * is appended. This helps provide preview snippets without breaking words.
 *
 * @param {string} text - The text to truncate.
 * @param {number} limit - Maximum number of characters.
 * @returns {string}
 */
function truncateText(text, limit) {
  if (!text || text.length <= limit) return text;
  const truncated = text.slice(0, limit);
  const lastSpace = truncated.lastIndexOf(' ');
  return truncated.slice(0, lastSpace > 0 ? lastSpace : limit) + '…';
}

/**
 * Create a DOM element for a project card. It displays the purpose as a
 * subtitle and a preview of the details. Clicking the "Read more" button
 * reveals the full details and responsibilities.
 *
 * @param {Object} project - The project data.
 * @returns {HTMLElement}
 */
function createProjectCard(project) {
  const card = document.createElement('div');
  card.className = 'card';

  // Image container
  const imgContainer = document.createElement('div');
  imgContainer.className = 'card__image-container';
  const img = document.createElement('img');
  img.src = project.image;
  img.alt = project.title;
  imgContainer.appendChild(img);

  // Content
  const content = document.createElement('div');
  content.className = 'card__content';
  // Title
  const title = document.createElement('h3');
  title.className = 'card__title';
  title.textContent = project.title;
  content.appendChild(title);
  // Subtitle (Purpose)
  const subtitle = document.createElement('p');
  subtitle.className = 'card__subtitle';
  subtitle.textContent = `Purpose: ${project.purpose}`;
  content.appendChild(subtitle);
  // Preview text
  const preview = document.createElement('p');
  preview.className = 'card__text';
  preview.textContent = truncateText(project.details, 180);
  content.appendChild(preview);
  // Hidden details container
  const details = document.createElement('div');
  details.className = 'card__text card__text--hidden';
  details.innerHTML =
    `<strong>Details:</strong> ${project.details}<br><strong>Responsibilities:</strong> ${project.responsibilities}`;
  content.appendChild(details);
  // Toggle button
  const btn = document.createElement('button');
  btn.className = 'btn btn--small card__toggle';
  btn.textContent = 'Read more';
  btn.addEventListener('click', () => {
    const isHidden = details.classList.contains('card__text--hidden');
    details.classList.toggle('card__text--hidden');
    btn.textContent = isHidden ? 'Show less' : 'Read more';
  });
  content.appendChild(btn);

  card.appendChild(imgContainer);
  card.appendChild(content);
  return card;
}

/**
 * Create a DOM element for an experiment card. It displays the hypothesis
 * as a subtitle and a preview of the details. Clicking the "Read more"
 * button reveals the full details and results.
 *
 * @param {Object} experiment - The experiment data.
 * @returns {HTMLElement}
 */
function createExperimentCard(experiment) {
  const card = document.createElement('div');
  card.className = 'card';

  // Image container
  const imgContainer = document.createElement('div');
  imgContainer.className = 'card__image-container';
  const img = document.createElement('img');
  img.src = experiment.image;
  img.alt = experiment.title;
  imgContainer.appendChild(img);

  // Content
  const content = document.createElement('div');
  content.className = 'card__content';
  const title = document.createElement('h3');
  title.className = 'card__title';
  title.textContent = experiment.title;
  content.appendChild(title);
  const subtitle = document.createElement('p');
  subtitle.className = 'card__subtitle';
  subtitle.textContent = `Hypothesis: ${experiment.hypothesis}`;
  content.appendChild(subtitle);
  const preview = document.createElement('p');
  preview.className = 'card__text';
  preview.textContent = truncateText(experiment.details, 180);
  content.appendChild(preview);
  // Hidden details
  const details = document.createElement('div');
  details.className = 'card__text card__text--hidden';
  details.innerHTML =
    `<strong>Details:</strong> ${experiment.details}<br><strong>Results:</strong> ${experiment.results}`;
  content.appendChild(details);
  // Toggle button
  const btn = document.createElement('button');
  btn.className = 'btn btn--small card__toggle';
  btn.textContent = 'Read more';
  btn.addEventListener('click', () => {
    const isHidden = details.classList.contains('card__text--hidden');
    details.classList.toggle('card__text--hidden');
    btn.textContent = isHidden ? 'Show less' : 'Read more';
  });
  content.appendChild(btn);

  card.appendChild(imgContainer);
  card.appendChild(content);
  return card;
}

/**
 * Entry point: populate the page after DOM is ready. This version uses
 * a minimal jQuery-like library to fetch the JSON file at runtime
 * and build the page dynamically. The carousels loop infinitely.
 */
$(function () {
  /**
   * Render the portfolio data into the DOM. This function is called
   * once the JSON data has been loaded successfully (either from
   * all_data_shortened.json or from the embedded fallback).
   *
   * @param {Object} data Portfolio data object
   */
  function renderPortfolio(data) {
    // Render portfolio data into the DOM.  When adding more
    // projects/experiments you only need to update the JSON file; the
    // dynamic JS will reflect those changes automatically.
    // Set introduction text
    if (data && data.intro) {
      $('#introText').text(data.intro);
    }

    // Build Projects cards
    const $projectsContainer = $('#projectsContainer');
    if (data && Array.isArray(data.projects) && $projectsContainer.length) {
      data.projects.forEach(function (project) {
        const card = createProjectCard(project);
        $projectsContainer[0].appendChild(card);
      });
    }

    // Build Experiments cards
    const $experimentsContainer = $('#experimentsContainer');
    if (data && Array.isArray(data.experiments) && $experimentsContainer.length) {
      data.experiments.forEach(function (experiment) {
        const card = createExperimentCard(experiment);
        $experimentsContainer[0].appendChild(card);
      });
    }

    // Setup the recommendation section. Always display the full
    // recommendation without collapse.  The intro paragraph holds the
    // complete letter; the toggle and full elements are hidden.  If
    // no recommendation is provided, hide the entire section.
    const $recommendationIntro = $('#recommendationIntro');
    const $recommendationFull = $('#recommendationFull');
    const $recommendationToggle = $('#recommendationToggle');
    if (data && data.recommendation && $recommendationIntro.length) {
      // Render the entire recommendation into the intro element
      $recommendationIntro.text(data.recommendation);
      // Hide the full text container and toggle button
      if ($recommendationFull.length) {
        $recommendationFull[0].style.display = 'none';
      }
      if ($recommendationToggle.length) {
        $recommendationToggle[0].style.display = 'none';
      }
    } else {
      // Hide the entire recommendation section if no data is provided
      const recSection = document.getElementById('recommendation');
      if (recSection) {
        recSection.style.display = 'none';
      }
    }

    // Reorder sections if an `order` array is provided in the JSON.  The
    // array should consist of section IDs (e.g., ["recommendation",
    // "projects", "experiments"]).  Sections are moved before the
    // footer to reflect the specified order.  Unknown IDs are ignored.
    if (data && Array.isArray(data.order)) {
      const footer = document.querySelector('footer');
      data.order.forEach(function (id) {
        const section = document.getElementById(id);
        if (section && section.parentElement && footer) {
          section.parentElement.insertBefore(section, footer);
        }
      });
    }

    // Initialize carousels with looping. Once the cards have been
    // rendered we can attach the carousel handlers. The initAllCarousels
    // function will safely ignore missing carousels.
    if (typeof initAllCarousels === 'function') {
      initAllCarousels();
    }
  }

  /**
   * Attempt to load the JSON file using the Fetch API. If this fails
   * (for instance due to CORS restrictions when using the file://
   * scheme), fall back to the embedded JSON inside the script tag with
   * id="portfolio-data".
   */
  function loadAndRender() {
    // Try to load the external JSON file first
    fetch('all_data_shortened.json')
      .then(function (response) {
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        return response.json();
      })
      .then(function (data) {
        renderPortfolio(data);
      })
      .catch(function () {
        // Fallback: parse the JSON embedded in the page
        const $embedded = $('#portfolio-data');
        if ($embedded.length) {
          try {
            const jsonText = $embedded[0].textContent || $embedded[0].innerText || '';
            const fallbackData = JSON.parse(jsonText);
            renderPortfolio(fallbackData);
          } catch (e) {
            console.error('Failed to parse embedded portfolio JSON', e);
          }
        }
      });
  }

  loadAndRender();
});

/**
 * Initialize a looping carousel for a container. The carousel loops back
 * to the beginning when advancing past the end and loops to the end
 * when rewinding past the beginning. The number of visible slides is
 * determined by the viewport width.
 *
 * @param {string} containerId The ID of the container holding the cards
 * @param {string} prevSelector CSS selector for the previous button
 * @param {string} nextSelector CSS selector for the next button
 */
// NOTE: The original initCarousel function has been removed because
// the portfolio now uses a simplified infinite carousel implemented in
// initAllCarousels(). If you wish to create a standalone carousel
// again, reintroduce and adapt the code accordingly.

/**
 * Initialize all carousels on the page. A carousel consists of a
 * wrapper element with class `.carousel` containing a `.carousel__inner`
 * element and navigation buttons `.carousel__btn--prev` and
 * `.carousel__btn--next`. This function attaches click handlers to
 * each button that update a per-carousel current index (stored in
 * `dataset.currentIndex` on the wrapper) and scrolls the inner
 * container accordingly. The carousels loop infinitely: clicking
 * beyond the last set of visible slides returns to the beginning and
 * vice versa. The number of slides visible depends on the viewport
 * width, matching the CSS breakpoints.
 */
/**
 * Initialize all carousels on the page.
 *
 * Each carousel is expected to have the structure:
 * <div class="carousel">
 *   <button class="carousel__btn carousel__btn--prev">Prev</button>
 *   <div class="carousel__inner"> ...cards... </div>
 *   <button class="carousel__btn carousel__btn--next">Next</button>
 * </div>
 *
 * This function attaches click handlers to the prev/next buttons so
 * that the inner container scrolls horizontally. The carousel loops
 * infinitely when reaching either end. The number of visible cards
 * depends on the viewport width, matching the CSS breakpoints.
 */
function initAllCarousels() {
  const carousels = document.querySelectorAll('.carousel');
  carousels.forEach(function (carousel) {
    const container = carousel.querySelector('.carousel__inner');
    const prevBtn = carousel.querySelector('.carousel__btn--prev');
    const nextBtn = carousel.querySelector('.carousel__btn--next');
    if (!container || !prevBtn || !nextBtn) return;

    // Compute full width of the first card (including margins). Returns 0 if none.
    function getCardWidth() {
      const first = container.children[0];
      if (!first) return 0;
      const style = window.getComputedStyle(first);
      const marginLeft = parseFloat(style.marginLeft) || 0;
      const marginRight = parseFloat(style.marginRight) || 0;
      return first.getBoundingClientRect().width + marginLeft + marginRight;
    }

    /**
     * Smoothly advance the carousel to the next card. The function
     * scrolls the container by one card width. After the scroll
     * completes it moves the first child to the end of the list and
     * adjusts the scroll position backwards so the cards appear to
     * continue seamlessly. The slight offset correction prevents a
     * noticeable jump and preserves the smooth animation.
     *
     * @param {Event} e
     */
    function handleNext(e) {
      if (e) e.preventDefault();
      const cardWidth = getCardWidth();
      if (!cardWidth) return;
      // Animate scroll to the next card
      container.scrollBy({ left: cardWidth, behavior: 'smooth' });
      // After the smooth scroll finishes, rotate elements and
      // reposition scrollLeft instantly (without animation). We
      // temporarily disable scrollSnapType and scrollBehavior to
      // prevent a second unintended animation when adjusting
      // scrollLeft. After the adjustment, we restore the original
      // styles on the next frame.
      setTimeout(function () {
        const first = container.firstElementChild;
        if (first) {
          container.appendChild(first);
        }
        const originalSnap = container.style.scrollSnapType;
        const originalBehavior = container.style.scrollBehavior;
        // Disable snapping and smooth scrolling
        container.style.scrollSnapType = 'none';
        container.style.scrollBehavior = 'auto';
        // Jump back by the width of one card to keep the same view
        container.scrollLeft -= cardWidth;
        requestAnimationFrame(function () {
          // Restore original snapping and smooth scrolling behaviour
          container.style.scrollSnapType = originalSnap || '';
          container.style.scrollBehavior = originalBehavior || '';
        });
      }, 350);
    }

    /**
     * Smoothly move the carousel backward by one card. To achieve a
     * seamless loop we first insert the last child at the beginning
     * and jump the scrollLeft forward by one card width. We then
     * animate scrolling back to the current position. This creates
     * the illusion of moving backwards infinitely without an abrupt
     * jump.
     *
     * @param {Event} e
     */
    function handlePrev(e) {
      if (e) e.preventDefault();
      const cardWidth = getCardWidth();
      if (!cardWidth) return;
      const last = container.lastElementChild;
      if (last) {
        const originalSnap = container.style.scrollSnapType;
        const originalBehavior = container.style.scrollBehavior;
        // Temporarily disable snap and smooth behaviour
        container.style.scrollSnapType = 'none';
        container.style.scrollBehavior = 'auto';
        // Move the last card to the front and shift scroll position
        container.insertBefore(last, container.firstElementChild);
        container.scrollLeft += cardWidth;
        requestAnimationFrame(function () {
          // Restore original behaviours and animate scroll back one card
          container.style.scrollSnapType = originalSnap || '';
          container.style.scrollBehavior = originalBehavior || '';
          container.scrollBy({ left: -cardWidth, behavior: 'smooth' });
        });
      }
    }

    nextBtn.addEventListener('click', handleNext);
    prevBtn.addEventListener('click', handlePrev);
  });
}
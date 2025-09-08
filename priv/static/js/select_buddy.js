/**
 * SelectBuddy Phoenix LiveView Hook
 * 
 * Provides client-side functionality for the SelectBuddy select_buddy component
 * including keyboard navigation, search debouncing, and accessibility features.
 */

const SelectBuddy = {
  mounted() {
    this.multiple = this.el.dataset.multiple === "true";
    this.searchDebounce = parseInt(this.el.dataset.searchDebounce || "300");
    this.searchTimeout = null;
    this.input = this.el.querySelector(".select-buddy-input");
    this.dropdown = this.el.querySelector(".dropdown");
    this.currentHighlight = -1;
    
    this.initializeEventListeners();
    this.setupKeyboardNavigation();
    this.setupClickOutside();
  },

  updated() {
    // Reset highlight when options change
    this.currentHighlight = -1;
    this.updateHighlight();
  },

  destroyed() {
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout);
    }
    document.removeEventListener("click", this.handleClickOutside);
  },

  initializeEventListeners() {
    // Search functionality with debouncing
    this.input.addEventListener("input", (e) => {
      if (this.searchTimeout) {
        clearTimeout(this.searchTimeout);
      }
      
      this.searchTimeout = setTimeout(() => {
        this.pushEvent("search", {
          query: e.target.value,
          field_name: this.getFieldName()
        });
      }, this.searchDebounce);
    });

    // Custom event listeners for component communication
    this.el.addEventListener("select-buddy:search", (e) => {
      // Handle search from external triggers
      const query = this.input.value;
      this.pushEvent("search", {
        query: query,
        field_name: this.getFieldName()
      });
    });

    this.el.addEventListener("select-buddy:blur", (e) => {
      // Delay hiding dropdown to allow for option clicks
      setTimeout(() => {
        this.pushEvent("hide_dropdown", {
          field_name: this.getFieldName()
        });
      }, 150);
    });

    this.el.addEventListener("select-buddy:keydown", (e) => {
      this.handleKeydown(e);
    });
  },

  setupKeyboardNavigation() {
    this.input.addEventListener("keydown", (e) => {
      if (!this.dropdown || this.dropdown.style.display === "none") {
        return;
      }

      const options = this.dropdown.querySelectorAll(".option");
      
      switch (e.key) {
        case "ArrowDown":
          e.preventDefault();
          this.currentHighlight = Math.min(this.currentHighlight + 1, options.length - 1);
          this.updateHighlight();
          break;
          
        case "ArrowUp":
          e.preventDefault();
          this.currentHighlight = Math.max(this.currentHighlight - 1, -1);
          this.updateHighlight();
          break;
          
        case "Enter":
          e.preventDefault();
          if (this.currentHighlight >= 0 && options[this.currentHighlight]) {
            options[this.currentHighlight].click();
          }
          break;
          
        case "Escape":
          e.preventDefault();
          this.pushEvent("hide_dropdown", {
            field_name: this.getFieldName()
          });
          this.input.blur();
          break;
          
        case "Tab":
          // Allow normal tab behavior but hide dropdown
          this.pushEvent("hide_dropdown", {
            field_name: this.getFieldName()
          });
          break;
      }
    });
  },

  setupClickOutside() {
    this.handleClickOutside = (e) => {
      if (!this.el.contains(e.target)) {
        this.pushEvent("hide_dropdown", {
          field_name: this.getFieldName()
        });
      }
    };
    
    document.addEventListener("click", this.handleClickOutside);
  },

  updateHighlight() {
    if (!this.dropdown) return;
    
    const options = this.dropdown.querySelectorAll(".option");
    
    options.forEach((option, index) => {
      if (index === this.currentHighlight) {
        option.classList.add("highlighted");
        option.setAttribute("aria-selected", "true");
        // Scroll into view if needed
        option.scrollIntoView({ block: "nearest" });
      } else {
        option.classList.remove("highlighted");
        option.setAttribute("aria-selected", "false");
      }
    });
  },

  getFieldName() {
    const hiddenInput = this.el.querySelector('input[type="hidden"]');
    return hiddenInput ? hiddenInput.name : "";
  },

  handleKeydown(e) {
    // This is called from the custom event
    // Additional keydown handling can be added here
  }
};

// Export for use in Phoenix applications
export default SelectBuddy;

// Also make available as global for non-module usage
if (typeof window !== "undefined") {
  window.SelectBuddy = SelectBuddy;
}

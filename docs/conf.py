# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

import os
import sys

# Add path to module
sys.path.insert(0, os.path.abspath("../"))

project = "bsys"
copyright = "2025, Ionuț Cicio"
author = "Ionuț Cicio"
release = "0.1.0"

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    "sphinx.ext.autodoc",
    "sphinx.ext.napoleon",
    "sphinx.ext.intersphinx",
    "sphinx.ext.viewcode",
]

pygments_style = "sphinx"
napoleon_google_docstring = True
napoleon_numpy_docstring = True
# highlight_language = "python"

templates_path = ["_templates"]
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]


# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

# html_theme = "python_docs_theme"
html_theme = "sphinxawesome_theme"
html_static_path = ["_static"]

autodoc_mock_imports = ["./src"]  # Replace with your package name

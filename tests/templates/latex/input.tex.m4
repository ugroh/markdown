\documentclass{minimal}
\csname UseRawInputEncoding\endcsname
% Load the package.
\usepackage{markdown}
\markdownSetup{theme=witiko/markdown/test}
% Load the support files.
\input setup\relax
% Load the test-specific setup.
\input TEST_SETUP_FILENAME\relax
\begin{document}
% Perform the test.
\markdownInput{TEST_INPUT_FILENAME}%
\end{document}

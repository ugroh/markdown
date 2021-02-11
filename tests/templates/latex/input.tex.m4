\documentclass{minimal}
\csname UseRawInputEncoding\endcsname
% Load the package.
\usepackage[theme=witiko/markdown/test]{markdown}
% Load the support files.
\input setup\relax
% Load the test-specific setup.
\input TEST_SETUP_FILENAME\relax
\begin{document}
% Perform the test.
\markdownInput{TEST_INPUT_FILENAME}%
\end{document}

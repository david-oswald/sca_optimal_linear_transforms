# Overview
This repo contains the MATLAB code for the paper "Improving side-channel analysis with optimal linear transforms" (CARDIS 2012). The paper and slides are available as PDF in this repo.

This code is quite old, so no warranties that it will run directly on your setup - you might have to tweak and update things. I tried it with MATLAB R2018b in 2019 and the simulation code was running fine. The code for the DPA v2 contest will definitely need proper paths and especially handling of the `AttackWrapper`.

# Other downloads
The used traceset etc from the DPA v2 contest can be found here: http://www.dpacontest.org/v2/download.php

# Cite
```
@InCollection{Oswald12_OptimalLinearTransforms,
  Title                    = {{Improving Side-Channel Analysis with Optimal Linear Transforms}},
  Author                   = {Oswald, David and Paar, Christof},
  Booktitle                = {Smart Card Research and Advanced Applications -- CARDIS'12},
  Publisher                = {Springer},
  Year                     = {2012},
  Editor                   = {Mangard, Stefan},
  Pages                    = {219-233},
  Series                   = {LNCS},
  Volume                   = {7771},
  Doi                      = {10.1007/978-3-642-37288-9_15},
  ISBN                     = {978-3-642-37287-2},
  Url                      = {https://github.com/david-oswald/sca_optimal_linear_transforms}
}
```

# License
All code in this repo is in the public domain, unless the header of a specific source file or the license in some directory says otherwise. The following license applies (expect if stated otherwise):

=======================================================================

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

=======================================================================

If this software is useful to you, I'd appreciate an attribution, contribution (e.g. bug fixes, improvements, ...), or a beer.

# Acknowledgements
The work described in the paper has been supported in part by the European Commission through the ICT program under contract ICT-2007-216676 ECRYPT II and by the German Federal Ministry of Education and Research BMBF (grant 01IS10026A, Project EXSET).

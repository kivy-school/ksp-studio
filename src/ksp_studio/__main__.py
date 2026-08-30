"""``python -m ksp_studio`` — same entry point as the ``ksp-studio`` script.

``commands.py`` spawns the background server through this rather than through
the console script, so it does not depend on the script directory being on
PATH.
"""

from . import main

raise SystemExit(main())

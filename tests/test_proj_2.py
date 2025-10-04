import pytest
import sys
from pathlib import Path

# Add project root to path to support imports
sys.path.insert(0, str(Path(__file__).parent.parent))

# Import from implementation (supports src/, package dir, or root)
try:
    from src.proj_2 import implement, validate
except ImportError:
    try:
        from proj_2 import implement, validate
    except ImportError:
        # If in a package directory, try importing from there
        import importlib.util
        spec = importlib.util.find_spec('proj_2')
        if spec:
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)
            implement = module.implement
            validate = module.validate
        else:
            raise

def test_proj_2_implementation():
    result = implement()
    assert result is not None

def test_proj_2_validation():
    assert validate() == True

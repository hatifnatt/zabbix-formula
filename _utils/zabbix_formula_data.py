"""
Additional functions to use in zabbix configuration templates
"""

import logging
from collections.abc import Mapping, Sequence

from salt.defaults import DEFAULT_TARGET_DELIM
from salt.utils.decorators.jinja import jinja_filter

log = logging.getLogger(__name__)


@jinja_filter("change_dict_case")
def change_case(data, attr, preserve_dict_class=False, process="both"):
    """
    Calls data.attr() if data has an attribute/method called attr.
    Processes data recursively if data is a Mapping or Sequence.
    For Mapping, processes keys, values or both depending on `process` argument.
    """
    if process not in ("keys", "values", "both"):
        raise AttributeError("change_case expect 'keys', 'values' or 'both' as value for 'process' argument")

    try:
        return getattr(data, attr)()
    except AttributeError:
        pass

    data_type = data.__class__

    if isinstance(data, Mapping):
        return (data_type if preserve_dict_class else dict)(
            (
                (change_case(key, attr, preserve_dict_class) if process in ("both", "keys") else key),
                (change_case(val, attr, preserve_dict_class) if process in ("both", "values") else val),
            )
            for key, val in data.items()
        )
    if isinstance(data, Sequence):
        return data_type(
            change_case(item, attr, preserve_dict_class) for item in data
        )
    return data


@jinja_filter("traverse_dict_keys")
def traverse_dict_keys(data, key, default=False, delimiter=DEFAULT_TARGET_DELIM):
    """
    Traverse a dict using a colon-delimited (or otherwise delimited, using the
    'delimiter' param) target string. The target 'foo:bar:baz' will return True
    if data['foo']['bar']['baz'] keys exists, and will otherwise return
    the default argument (False).
    """
    ptr = data
    try:
        for each in key.split(delimiter):
            ptr = ptr[each]
    except (KeyError, IndexError, TypeError):
        # Encountered a non-indexable value in the middle of traversing
        return default
    return True

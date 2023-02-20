import os


def override_path():
    resource_path = {
        "staging": os.environ.get("stage_path"),
        "resource": os.environ.get("resource_path"),
    }
    return resource_path

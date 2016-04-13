# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from h.api.search.index import index


def index_annotation_event(event):
    """Index a created, updated or deleted annotation into Elasticsearch."""
    if not event.request.feature('postgres'):
        return

    if event.action == 'create':
        index(event.request.es, event.annotation, event.request)

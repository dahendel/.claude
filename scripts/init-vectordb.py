#!/usr/bin/env python3
"""
Initialize Claude Vector Database Collections
Creates standard collections for optimal organization
"""

import sys
import time
from pathlib import Path

try:
    import chromadb
    from chromadb.config import Settings
except ImportError:
    print("❌ chromadb not installed")
    print("Install with: pip install chromadb")
    sys.exit(1)


CLAUDE_DIR = Path.home() / ".claude"
CHROMA_DATA = CLAUDE_DIR / "chroma-data"


def init_collections():
    """Initialize standard vector database collections"""

    print("🚀 Initializing Claude Vector Database...")
    print()

    # Ensure directory exists
    CHROMA_DATA.mkdir(parents=True, exist_ok=True)

    # Connect to Chroma (try HTTP first, then local)
    try:
        # Try HTTP connection (Docker)
        print("Attempting HTTP connection to Chroma...")
        client = chromadb.HttpClient(host="localhost", port=8000)
        client.heartbeat()
        print("✅ Connected to Chroma via HTTP (Docker)")
    except Exception as e:
        print(f"⚠️  HTTP connection failed: {e}")
        print("Attempting local persistent connection...")

        try:
            # Fall back to local persistent
            client = chromadb.PersistentClient(
                path=str(CHROMA_DATA),
                settings=Settings(anonymized_telemetry=False)
            )
            print("✅ Connected to Chroma (local persistent)")
        except Exception as e:
            print(f"❌ Failed to connect to Chroma: {e}")
            print()
            print("Try starting Docker services first:")
            print("  docker compose up -d")
            sys.exit(1)

    print()

    # Define standard collections
    collections = [
        {
            "name": "claude-memory",
            "metadata": {
                "description": "General conversation memory and context",
                "hnsw:space": "cosine"
            }
        },
        {
            "name": "code-context",
            "metadata": {
                "description": "Code snippets and programming context",
                "hnsw:space": "cosine"
            }
        },
        {
            "name": "architecture-decisions",
            "metadata": {
                "description": "Design decisions and architectural patterns",
                "hnsw:space": "cosine"
            }
        },
        {
            "name": "project-notes",
            "metadata": {
                "description": "Project-specific notes and documentation",
                "hnsw:space": "cosine"
            }
        }
    ]

    # Create collections
    created = []
    existing = []

    for coll_config in collections:
        name = coll_config["name"]
        metadata = coll_config["metadata"]

        try:
            collection = client.get_or_create_collection(
                name=name,
                metadata=metadata
            )

            # Check if it already existed
            if collection.count() > 0:
                existing.append((name, collection.count()))
            else:
                created.append(name)

            print(f"✓ Collection: {name}")
            print(f"  Documents: {collection.count()}")
            print(f"  Description: {metadata['description']}")
            print()

        except Exception as e:
            print(f"❌ Failed to create collection '{name}': {e}")
            print()

    # Summary
    print("="*60)
    print("Summary:")
    print(f"  Created: {len(created)} new collection(s)")
    print(f"  Existing: {len(existing)} collection(s) with data")
    print()

    if created:
        print("New collections:")
        for name in created:
            print(f"  • {name}")
        print()

    if existing:
        print("Existing collections:")
        for name, count in existing:
            print(f"  • {name} ({count} documents)")
        print()

    # Test write
    print("Testing write capability...")
    try:
        test_collection = client.get_collection("claude-memory")
        test_collection.add(
            ids=[f"test_{int(time.time())}"],
            documents=["Test document for initialization"],
            metadatas=[{"type": "test", "timestamp": time.time()}]
        )
        print("✅ Write test successful")
    except Exception as e:
        print(f"⚠️  Write test failed: {e}")

    print()
    print("✅ Vector database initialization complete!")
    print()
    print("Usage in Claude:")
    print('  "Store in memory: {your important context}"')
    print('  "What do you remember about {topic}?"')
    print()


if __name__ == "__main__":
    init_collections()

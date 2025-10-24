#!/usr/bin/env python3
"""
Initialize Claude Vector Database
Creates collections and optionally imports initial data
"""

import sys
import json
import requests
from datetime import datetime
from pathlib import Path

CHROMA_URL = "http://localhost:8000"
CLAUDE_DIR = Path.home() / ".claude"

def check_connection():
    """Check if Chroma is running"""
    try:
        response = requests.get(f"{CHROMA_URL}/api/v1/heartbeat", timeout=5)
        return response.status_code == 200
    except:
        return False

def create_collection(name, metadata=None):
    """Create a Chroma collection"""
    data = {"name": name}
    if metadata:
        data["metadata"] = metadata

    try:
        response = requests.post(
            f"{CHROMA_URL}/api/v1/collections",
            json=data,
            headers={"Content-Type": "application/json"}
        )

        if response.status_code in [200, 201]:
            print(f"  ✓ Created collection: {name}")
            return True
        elif response.status_code == 409:
            print(f"  ℹ Collection already exists: {name}")
            return True
        else:
            print(f"  ✗ Failed to create {name}: {response.text}")
            return False
    except Exception as e:
        print(f"  ✗ Error creating {name}: {e}")
        return False

def list_collections():
    """List all collections"""
    try:
        response = requests.get(f"{CHROMA_URL}/api/v1/collections")
        if response.status_code == 200:
            collections = response.json()
            return collections if isinstance(collections, list) else []
        return []
    except:
        return []

def add_sample_data(collection_name, documents):
    """Add sample documents to a collection"""
    try:
        # First, get the collection
        response = requests.get(f"{CHROMA_URL}/api/v1/collections/{collection_name}")
        if response.status_code != 200:
            print(f"  ✗ Collection {collection_name} not found")
            return False

        # Prepare data
        ids = [f"doc_{i}" for i in range(len(documents))]
        metadatas = [{"source": "initialization", "timestamp": datetime.now().isoformat()}] * len(documents)

        data = {
            "ids": ids,
            "documents": documents,
            "metadatas": metadatas
        }

        # Add documents
        response = requests.post(
            f"{CHROMA_URL}/api/v1/collections/{collection_name}/add",
            json=data,
            headers={"Content-Type": "application/json"}
        )

        if response.status_code in [200, 201]:
            print(f"  ✓ Added {len(documents)} documents to {collection_name}")
            return True
        else:
            print(f"  ✗ Failed to add documents: {response.text}")
            return False
    except Exception as e:
        print(f"  ✗ Error adding documents: {e}")
        return False

def main():
    print("=" * 60)
    print("Claude Vector Database Initialization")
    print("=" * 60)
    print()

    # Check connection
    print("Checking Chroma connection...")
    if not check_connection():
        print("✗ Cannot connect to Chroma at", CHROMA_URL)
        print()
        print("Make sure services are running:")
        print("  claude-services start")
        sys.exit(1)

    print("✓ Connected to Chroma")
    print()

    # Create standard collections
    print("Creating collections...")

    collections = {
        "claude-memory": {
            "description": "General conversation memory",
            "hnsw:space": "cosine"
        },
        "code-context": {
            "description": "Code snippets and technical context",
            "hnsw:space": "cosine"
        },
        "architecture-decisions": {
            "description": "Architecture decisions and rationale",
            "hnsw:space": "cosine"
        },
        "project-notes": {
            "description": "Project-specific notes and context",
            "hnsw:space": "cosine"
        }
    }

    success_count = 0
    for name, metadata in collections.items():
        if create_collection(name, metadata):
            success_count += 1

    print()
    print(f"✓ {success_count}/{len(collections)} collections ready")
    print()

    # Optionally add sample data
    if len(sys.argv) > 1 and sys.argv[1] == "--with-samples":
        print("Adding sample data...")

        sample_docs = [
            "Setup completed on " + datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "Claude Code optimization environment initialized",
            "Vector database ready for persistent memory across sessions"
        ]

        add_sample_data("claude-memory", sample_docs)
        print()

    # Show summary
    print("=" * 60)
    print("Summary")
    print("=" * 60)

    all_collections = list_collections()
    print(f"Total collections: {len(all_collections)}")

    for coll in all_collections:
        print(f"  - {coll.get('name', 'unknown')}")

    print()
    print("✓ Vector database initialization complete!")
    print()
    print("Next steps:")
    print("  1. Configure MCP: cp ~/.claude/claude_desktop_config_docker.json")
    print("     to your Claude Desktop config location")
    print("  2. Restart Claude Desktop")
    print("  3. Test: 'Store in memory: Test successful'")
    print()

if __name__ == "__main__":
    main()

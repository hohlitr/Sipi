package com.hohlitr.sipi

import android.content.SharedPreferences
import org.json.JSONArray

class SipiStore(private val prefs: SharedPreferences) {
    val collections = mutableListOf<StudyCollection>()
    val cards = mutableListOf<CardItem>()
    val groups = mutableListOf<CardGroup>()
    val plans = mutableListOf<StudyPlan>()

    var currentUserEmail: String = DEFAULT_EMAIL

    fun loadData(): Boolean {
        currentUserEmail = prefs.getString(KEY_EMAIL, DEFAULT_EMAIL) ?: DEFAULT_EMAIL
        clear()

        val collectionsRaw = prefs.getString(KEY_COLLECTIONS, null)
        if (collectionsRaw == null) {
            resetToDemoData()
            return false
        }

        return runCatching {
            JSONArray(collectionsRaw).forEachObject {
                collections.add(StudyCollection.fromJson(it))
            }
            JSONArray(prefs.getString(KEY_CARDS, "[]")).forEachObject {
                cards.add(CardItem.fromJson(it))
            }
            JSONArray(prefs.getString(KEY_GROUPS, "[]")).forEachObject {
                groups.add(CardGroup.fromJson(it))
            }
            JSONArray(prefs.getString(KEY_PLANS, "[]")).forEachObject {
                plans.add(StudyPlan.fromJson(it))
            }
        }.fold(
            onSuccess = { false },
            onFailure = {
                resetToDemoData()
                true
            },
        )
    }

    fun saveCurrentUserEmail() {
        prefs.edit().putString(KEY_EMAIL, currentUserEmail).apply()
    }

    fun saveData() {
        prefs.edit()
            .putString(KEY_COLLECTIONS, JSONArray(collections.map { it.toJson() }).toString())
            .putString(KEY_CARDS, JSONArray(cards.map { it.toJson() }).toString())
            .putString(KEY_GROUPS, JSONArray(groups.map { it.toJson() }).toString())
            .putString(KEY_PLANS, JSONArray(plans.map { it.toJson() }).toString())
            .apply()
    }

    fun resetToDemoData() {
        seedData()
        saveData()
    }

    fun deleteCollection(collectionId: String) {
        collections.removeAll { it.id == collectionId }
        cards.removeAll { it.collectionId == collectionId }
        groups.removeAll { it.collectionId == collectionId }
        plans.removeAll { it.collectionId == collectionId }
        saveData()
    }

    private fun seedData() {
        clear()
        collections.add(
            StudyCollection(
                id = "bio",
                title = "Биология: базовые термины",
                description = "Демо-набор для проверки режима чтения, теста и прогресса",
                createdAt = now(),
                updatedAt = now(),
            )
        )
        cards.addAll(
            listOf(
                CardItem("bio-1", "bio", "Что такое клетка?", "Клетка - основная структурная и функциональная единица живого организма.", "Начать с краткого определения.", 2, 3, 0.66),
                CardItem("bio-2", "bio", "Что хранит наследственную информацию?", "Наследственную информацию хранит ДНК.", "", 1, 3, 0.33),
                CardItem("bio-3", "bio", "Что такое фотосинтез?", "Фотосинтез - процесс образования органических веществ из неорганических под действием света.", "", 0, 1, 0.0),
            )
        )
        groups.add(CardGroup("group-bio", "bio", "Важные определения", cards.map { it.id }))
        plans.add(StudyPlan("plan-bio", "bio", now(), "через 14 дн.", 0.8))
    }

    private fun clear() {
        collections.clear()
        cards.clear()
        groups.clear()
        plans.clear()
    }

    private fun now() = System.currentTimeMillis().toString()

    private companion object {
        const val DEFAULT_EMAIL = "student@example.com"
        const val KEY_EMAIL = "email"
        const val KEY_COLLECTIONS = "collections"
        const val KEY_CARDS = "cards"
        const val KEY_GROUPS = "groups"
        const val KEY_PLANS = "plans"
    }
}

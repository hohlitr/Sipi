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
            onSuccess = {
                migrateDemoDataIfNeeded()
                false
            },
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
        collections.addAll(
            listOf(
                StudyCollection(
                    id = "kotlin-basics",
                    title = "Kotlin: базовые понятия",
                    description = "Переменные, функции, null-safety и коллекции для старта в Android-разработке",
                    createdAt = now(),
                    updatedAt = now(),
                ),
                StudyCollection(
                    id = "oop-basics",
                    title = "ООП и архитектура",
                    description = "Классы, наследование, интерфейсы и разделение ответственности в приложении",
                    createdAt = now(),
                    updatedAt = now(),
                ),
            )
        )
        cards.addAll(
            listOf(
                CardItem(
                    id = "kotlin-1",
                    collectionId = "kotlin-basics",
                    question = "Что такое val в Kotlin?",
                    answer = "val объявляет неизменяемую ссылку, которую нельзя переназначить после инициализации.",
                    note = "Похоже на final-переменную.",
                    wrongAnswers = listOf(
                        "val объявляет переменную, которую обязательно нужно менять в цикле.",
                        "val создает функцию без параметров.",
                        "val отключает проверку null в Kotlin.",
                    ),
                    correctAnswers = 2,
                    attempts = 3,
                    mastery = 0.66,
                ),
                CardItem(
                    id = "kotlin-2",
                    collectionId = "kotlin-basics",
                    question = "Для чего нужен nullable-тип String?",
                    answer = "String? показывает, что переменная может хранить строку или null.",
                    note = "Знак вопроса делает null явной частью типа.",
                    wrongAnswers = listOf(
                        "String? означает, что строка всегда пустая.",
                        "String? запрещает присваивать null.",
                        "String? автоматически переводит текст в верхний регистр.",
                    ),
                    correctAnswers = 1,
                    attempts = 3,
                    mastery = 0.33,
                ),
                CardItem(
                    id = "kotlin-3",
                    collectionId = "kotlin-basics",
                    question = "Что делает функция map у коллекции?",
                    answer = "map преобразует каждый элемент коллекции и возвращает новую коллекцию результатов.",
                    note = "",
                    wrongAnswers = listOf(
                        "map удаляет все элементы коллекции.",
                        "map сортирует коллекцию по алфавиту без преобразования.",
                        "map сохраняет коллекцию в SharedPreferences.",
                    ),
                    correctAnswers = 0,
                    attempts = 1,
                    mastery = 0.0,
                ),
                CardItem(
                    id = "oop-1",
                    collectionId = "oop-basics",
                    question = "Что такое инкапсуляция?",
                    answer = "Инкапсуляция скрывает внутреннее состояние объекта и открывает доступ через понятный интерфейс.",
                    note = "Снижает зависимость внешнего кода от деталей реализации.",
                    wrongAnswers = listOf(
                        "Инкапсуляция означает копирование всех классов в один файл.",
                        "Инкапсуляция запрещает создавать методы в классе.",
                        "Инкапсуляция нужна только для изменения цвета интерфейса.",
                    ),
                    correctAnswers = 2,
                    attempts = 4,
                    mastery = 0.5,
                ),
                CardItem(
                    id = "oop-2",
                    collectionId = "oop-basics",
                    question = "Зачем нужен интерфейс?",
                    answer = "Интерфейс задает контракт поведения без привязки к конкретной реализации.",
                    note = "",
                    wrongAnswers = listOf(
                        "Интерфейс хранит только изображения приложения.",
                        "Интерфейс всегда содержит готовую базу данных.",
                        "Интерфейс нужен только для запуска эмулятора.",
                    ),
                    correctAnswers = 1,
                    attempts = 2,
                    mastery = 0.5,
                ),
                CardItem(
                    id = "oop-3",
                    collectionId = "oop-basics",
                    question = "Что означает разделение ответственности?",
                    answer = "Разделение ответственности означает, что каждый класс или модуль отвечает за одну понятную часть логики.",
                    note = "Такой код проще тестировать и менять.",
                    wrongAnswers = listOf(
                        "Разделение ответственности означает, что весь код должен быть в MainActivity.",
                        "Разделение ответственности запрещает использовать отдельные файлы.",
                        "Разделение ответственности нужно только для увеличения размера APK.",
                    ),
                    correctAnswers = 0,
                    attempts = 1,
                    mastery = 0.0,
                ),
            )
        )
        groups.add(CardGroup("group-kotlin", "kotlin-basics", "Основы Kotlin", cards.filter { it.collectionId == "kotlin-basics" }.map { it.id }))
        groups.add(CardGroup("group-oop", "oop-basics", "Архитектурные понятия", cards.filter { it.collectionId == "oop-basics" }.map { it.id }))
        plans.add(StudyPlan("plan-kotlin", "kotlin-basics", now(), "через 10 дн.", 0.8))
        plans.add(StudyPlan("plan-oop", "oop-basics", now(), "через 14 дн.", 0.75))
    }

    private fun migrateDemoDataIfNeeded() {
        val hasLegacyBioDemo = collections.any { it.id == "bio" }
        val hasProgrammingDemo = collections.any { it.id == "kotlin-basics" || it.id == "oop-basics" }
        ensureDemoWrongAnswers()
        if (!hasLegacyBioDemo && hasProgrammingDemo) return

        collections.removeAll { it.id == "bio" }
        cards.removeAll { it.collectionId == "bio" }
        groups.removeAll { it.collectionId == "bio" }
        plans.removeAll { it.collectionId == "bio" }

        if (!hasProgrammingDemo) {
            val userCollections = collections.toList()
            val userCards = cards.toList()
            val userGroups = groups.toList()
            val userPlans = plans.toList()
            seedData()
            collections.addAll(userCollections)
            cards.addAll(userCards)
            groups.addAll(userGroups)
            plans.addAll(userPlans)
        }
        ensureDemoWrongAnswers()
        saveData()
    }

    private fun ensureDemoWrongAnswers() {
        var changed = false
        cards.replaceAll { card ->
            val wrongAnswers = demoWrongAnswers[card.id].orEmpty()
            if (wrongAnswers.isNotEmpty() && card.wrongAnswers.isEmpty()) {
                changed = true
                card.copy(wrongAnswers = wrongAnswers)
            } else {
                card
            }
        }
        if (changed) saveData()
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

        val demoWrongAnswers = mapOf(
            "kotlin-1" to listOf(
                "val объявляет переменную, которую обязательно нужно менять в цикле.",
                "val создает функцию без параметров.",
                "val отключает проверку null в Kotlin.",
            ),
            "kotlin-2" to listOf(
                "String? означает, что строка всегда пустая.",
                "String? запрещает присваивать null.",
                "String? автоматически переводит текст в верхний регистр.",
            ),
            "kotlin-3" to listOf(
                "map удаляет все элементы коллекции.",
                "map сортирует коллекцию по алфавиту без преобразования.",
                "map сохраняет коллекцию в SharedPreferences.",
            ),
            "oop-1" to listOf(
                "Инкапсуляция означает копирование всех классов в один файл.",
                "Инкапсуляция запрещает создавать методы в классе.",
                "Инкапсуляция нужна только для изменения цвета интерфейса.",
            ),
            "oop-2" to listOf(
                "Интерфейс хранит только изображения приложения.",
                "Интерфейс всегда содержит готовую базу данных.",
                "Интерфейс нужен только для запуска эмулятора.",
            ),
            "oop-3" to listOf(
                "Разделение ответственности означает, что весь код должен быть в MainActivity.",
                "Разделение ответственности запрещает использовать отдельные файлы.",
                "Разделение ответственности нужно только для увеличения размера APK.",
            ),
        )
    }
}

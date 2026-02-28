import Foundation

/**
 * @struct TriangleCoordinate
 * @brief Represents a coordinate in a triangular grid based on the hexagonal cubic coordinate system.
 */
struct TriangleCoordinate: Hashable {
    
    /**
     * @brief The 'q' axis of the cubic coordinate system.
     * @details One of the three axes in a hexagonal grid (q, r, s).
     */
    let q: Int
    
    /**
     * @brief The 'r' axis of the cubic coordinate system.
     * @details One of the three axes in a hexagonal grid (q, r, s).
     */
    let r: Int
    
    /**
     * @brief The 's' axis of the cubic coordinate system.
     * @details Derived from q and r such that q + r + s = 0. Stored for convenience and hashing.
     */
    let s: Int
    
    /**
     * @brief The orientation of the triangle at this coordinate.
     * @details True if the triangle points up (apex at top), false if it points down (apex at bottom).
     */
    let isPointingUp: Bool
    
    /**
     * @brief Initializes a new TriangleCoordinate.
     * @param q The column coordinate.
     * @param r The row coordinate.
     * @param isPointingUp The orientation of the triangle.
     * @note The 's' coordinate is automatically calculated to satisfy the cubic constraint q + r + s = 0.
     */
    init(q: Int, r: Int, isPointingUp: Bool) {
        self.q = q
        self.r = r
        self.s = -(q + r) // Enforce q + r + s = 0
        self.isPointingUp = isPointingUp
    }
}

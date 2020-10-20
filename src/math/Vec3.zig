const math = @import("std").math;
usingnamespace @import("MathUtil.zig");

pub const Vec3 = packed struct {
    x: f32 = 0.0,
    y: f32 = 0.0,
    z: f32 = 0.0,

    pub inline fn Scale(self: *Vec3, scalar: f32) void {
        self.x *= scalar;
        self.y *= scalar;
        self.z *= scalar;
    }

    pub inline fn GetScaled(self: *const Vec3, scalar: f32) Vec3 {
        return Vec3{
            .x = self.x * scalar,
            .y = self.y * scalar,
            .z = self.z * scalar,
        };
    }

    pub inline fn Add(self: *const Vec3, rhs: Vec3) Vec3 {
        return Vec3{
            .x = self.x + rhs.x,
            .y = self.y + rhs.y,
            .z = self.z + rhs.z,
        };
    }

    pub inline fn Sub(self: *const Vec3, rhs: Vec3) Vec3 {
        return Vec3{
            .x = self.x - rhs.x,
            .y = self.y - rhs.y,
            .z = self.z - rhs.z,
        };
    }

    pub inline fn Dot(self: *const Vec3, rhs: Vec3) Vec3 {
        return Vec3{
            .x = self.x * rhs.x,
            .y = self.y * rhs.y,
            .z = self.z * rhs.z,
        };
    }

    pub inline fn Cross(self: *const Vec3, rhs: Vec3) Vec3 {
        return Vec3{
            .x = self.y * rhs.z - self.z * rhs.y,
            .y = self.z * rhs.x - self.x * rhs.z,
            .z = self.x * rhs.y - self.y * rhs.x,
        };
    }

    // equals with a default tolerance of f32_epsilon
    pub inline fn Equals(self: *const Vec3, rhs: Vec3) bool {
        return self.EqualsT(rhs, math.f32_epsilon);
    }

    pub inline fn EqualsT(self: *const Vec3, rhs: Vec3, tolerance: f32) bool {
        return EqualWithinTolerance(f32, self.x, rhs.x, tolerance) and
            EqualWithinTolerance(f32, self.y, rhs.y, tolerance) and
            EqualWithinTolerance(f32, self.z, rhs.z, tolerance);
    }

    pub inline fn LengthSqrd(self: *const Vec3) f32 {
        return self.x * self.x + self.y * self.y + self.z * self.z;
    }

    pub inline fn Length(self: *const Vec3) f32 {
        return math.sqrt(self.LengthSqrd());
    }

    pub inline fn DistSqrd(self: *const Vec3, rhs: Vec3) f32 {
        return self.Sub(rhs).LengthSqrd();
    }

    pub inline fn Dist(self: *const Vec3, rhs: Vec3) f32 {
        return self.Sub(rhs).Length();
    }

    //TODO panics in debug build only maybe?

    pub inline fn ClampToMinSize(self: *Vec3, size: f32) void {
        const lengthSqrd = self.LengthSqrd();
        const sizeSqrd = size * size;
        if (lengthSqrd < sizeSqrd) {
            if (lengthSqrd == 0.0) @panic("Clamping vector with length 0");
            const inv = size / math.sqrt(lengthSqrd);
            self.x *= inv;
            self.y *= inv;
            self.z *= inv;
        }
    }

    pub inline fn ClampToMaxSize(self: *Vec3, size: f32) void {
        const lengthSqrd = self.LengthSqrd();
        const sizeSqrd = size * size;
        if (lengthSqrd > sizeSqrd) {
            if (lengthSqrd == 0.0) @panic("Clamping vector with length 0");
            const inv = size / math.sqrt(lengthSqrd);
            self.x *= inv;
            self.y *= inv;
            self.z *= inv;
        }
    }

    pub inline fn GetClampedToMinSize(self: *const Vec3, size: f32) Vec3 {
        const lengthSqrd = self.LengthSqrd();
        const sizeSqrd = size * size;
        if (lengthSqrd < sizeSqrd) {
            if (lengthSqrd == 0.0) @panic("Clamping vector with length 0");
            const inv = size / math.sqrt(lengthSqrd);
            return Vec3{
                .x = self.x * inv,
                .y = self.y * inv,
                .z = self.z * inv,
            };
        }
    }

    pub inline fn GetClampedToMaxSize(self: *const Vec3, size: f32) Vec3 {
        const lengthSqrd = self.LengthSqrd();
        const sizeSqrd = size * size;
        if (lengthSqrd > sizeSqrd) {
            if (lengthSqrd == 0.0) @panic("Clamping vector with length 0");
            const inv = size / math.sqrt(lengthSqrd);
            return Vec3{
                .x = self.x * inv,
                .y = self.y * inv,
                .z = self.z * inv,
            };
        }
    }

    pub inline fn ScaleToSize(self: *Vec3, size: f32) void {
        const length = self.Length();
        if (length == 0.0) @panic("Trying to scale up a vector with length 0");
        const scaleAmount = size / length;
        self.Scale(scaleAmount);
    }

    pub inline fn GetScaledToSize(self: *Vec3, size: f32) Vec3 {
        const length = self.Length();
        if (length == 0.0) @panic("Trying to scale up a vector with length 0");
        const scaleAmount = size / length;
        return self.GetScaled(scaleAmount);
    }

    pub inline fn Normalized(self: *Vec3) Vec3 {
        const length = self.Length();
        if (length == 0.0) @panic("Normalizing vector with length 0");
        return Vec3{
            .x = self.x / length,
            .y = self.y / length,
            .z = self.z / length,
        };
    }

    pub inline fn NormalizeSelf(self: *Vec3) void {
        const length = self.Length();
        if (length == 0.0) @panic("Normalizing vector with length 0");
        self.x /= length;
        self.y /= length;
        self.z /= length;
    }
};

pub inline fn Vec3_xy0(v2: *const Vec2) Vec3 {
    return Vec3{ v2.x, v2.y, 0.0 };
}

pub inline fn Vec3_x0y(v2: *const Vec2) Vec3 {
    return Vec3{ v2.x, 0.0, v2.y };
}

pub inline fn Vec3_0xy(v2: *const Vec2) Vec3 {
    return Vec3{ 0.0, v2.x, v2.y };
}

//TODO testing
test "eden.math.Vec3" {
    const debug = @import("std").debug;
    const assert = debug.assert;
    {
        const v1 = Vec3{ .x = 1.0, .y = 2.0, .z = 3.0 };
        const v2 = Vec3{ .x = 3.0, .y = 2.0, .z = 3.0 };
        const v3 = v1.Add(v2);
        assert(v3.x == 4.0 and v3.y == 4.0 and v3.z == 4.0);
    }
}

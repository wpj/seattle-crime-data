gulp          = require('gulp');
gutil         = require('gulp-util');
gulpif        = require('gulp-if');
changed       = require('gulp-changed');
concat        = require('gulp-concat');
uglify        = require('gulp-uglify');
coffee        = require('gulp-coffee');
sass          = require('gulp-sass');
browserSync   = require('browser-sync');
reload        = browserSync.reload;
minifyCSS     = require('gulp-minify-css');
imageMin      = require('gulp-imagemin');
htmlMin       = require('gulp-htmlmin');
sourcemaps    = require('gulp-sourcemaps');
mainFiles     = require('main-bower-files');
templateCache = require('gulp-angular-templatecache');
browserify    = require('browserify');
debowerify    = require('debowerify');
coffeeify     = require('coffeeify');
streamify     = require('gulp-streamify');
source        = require('vinyl-source-stream');
buffer        = require('vinyl-buffer');
watchify      = require('watchify');
queue         = require('streamqueue');
bourbon       = require('node-bourbon');

gulp.task('browser-sync', function() {
  browserSync({
    open: false,
    notify: false,
    server: { baseDir: './dist' }
  });
});

gulp.task('js', function() {
  scripts = browserify('./src/js/index.coffee', { extensions: ['.js', '.coffee'], debug: true })
    .transform(coffeeify)
    .transform(debowerify)
    .bundle()
    .pipe(source('browserify-bundle.js'))
    .pipe(buffer());

  templates = gulp.src('src/views/**/*')
    .pipe(htmlMin({ collapseWhitespace: true }))
    .pipe(templateCache({
      module: 'app.templates',
      standalone: true
    }));

  queue({ objectMode: true }, scripts, templates)
    .pipe(concat('bundle.js'))
    // .pipe(uglify())
    .pipe(gulp.dest('dist/js'))
    .pipe(reload({ stream: true }));
});

gulp.task('bower', function() {
  gulp.src(mainFiles(), { base: 'bower_components' })
    .pipe(gulp.dest('dist/lib'));
});

gulp.task('views', function() {
  gulp.src('src/index.html')
    // .pipe(htmlMin({ collapseWhitespace: true }))
    .pipe(gulp.dest('dist/'))
    .pipe(reload({ stream: true }));
});

gulp.task('styles', function() {
  gulp.src('src/styles/*.scss')
    .pipe(changed('dist/css'))
    .pipe(sass({
      includePaths: bourbon.with('./src/styles'),
      onError: function(e) { console.log(e); }
    }))
    // .pipe(minifyCSS())
    .pipe(gulp.dest('dist/css/'))
    .pipe(reload({ stream: true }));
});

gulp.task('img', function() {
  gulp.src('src/img/**.*')
    .pipe(imageMin({ optimizationLevel: 7 }))
    .pipe(gulp.dest('dist/img'));
});

gulp.task('misc-dependencies', function() {
  gulp.src('src/misc/**/*')
    .pipe(gulp.dest('dist'));
});

gulp.task('watch', function() {
  gulp.watch(['src/js/**', 'src/js/**/*.js', 'src/views/**'], ['js']);
  gulp.watch(['src/index.html'], ['views']);
  gulp.watch(['src/styles/**'], ['styles']);
});

gulp.task('default', ['browser-sync', 'build', 'watch']);

gulp.task('build', ['js', 'views', 'styles', 'img', 'bower', 'misc-dependencies']);
